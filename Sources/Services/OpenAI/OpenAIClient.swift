//
//  OpenAIClient.swift
//  ALog
//
//  Created by Xin Du on 2023/07/14.
//

import Foundation
import XLog
import CryptoKit
import ArkanaKeys

struct OpenAIResponse {
    struct Error: Codable {
        let error: ErrorBody
        struct ErrorBody: Codable {
            let message: String
            let code: String?
        }
    }
    
    struct Transcription: Codable {
        let text: String
    }
    
    struct Chat: Codable {
        let choices: [Choice]
        let usage: Usage
        
        struct Choice: Codable {
            let finish_reason: String
            let message: Message
        }
        
        struct Message: Codable {
            let role: String
            let content: String
        }
        
        struct Usage: Codable {
            let prompt_tokens: Int
            let completion_tokens: Int
            let total_tokens: Int
        }
    }
    
    struct Chunk: Codable {
        let choices: [Choice]
        
        struct Choice: Codable {
            struct Delta: Codable {
                let role: String?
                let content: String?
            }
            let delta: Delta
        }
    }
}

enum OpenAIError: LocalizedError {
    case badResponse(String)
    case decoding(Error)
    case apiError(Int, OpenAIResponse.Error)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .badResponse(_): return "Bad Response"
        case .apiError(let code, let res): return "\(code). \(res.error.message)"
        case .decoding(_): return "Decoding Error"
        case .unknown(_): return "Unknown Error"
        }
    }
}

class OpenAIClient {
    static let shared = OpenAIClient()
    private let TAG = "OpenAI"
    
    private var baseURL: URL {
        guard Config.shared.serverType == .custom else {
            return Constants.api_base_url
        }
        
        return URL(string: Config.shared.serverHost)!
    }
    
    private var apiKey: String? {
        guard Config.shared.serverType == .custom else {
            return nil
        }
        
        let key = Config.shared.serverAPIKey
        return key.isEmpty ? nil : key
    }
    
    private var requiresHMAC: Bool {
        Config.shared.serverType == .app
    }
    
    // MARK: - Verification
    
    /// 验证 chat 接口
    func verify(_ host: String, key: String?) async throws {
        guard let hostURL = URL(string: host) else {
            throw URLError(.badURL)
        }
        
        let url = hostURL.appending(path: "v1/chat/completions")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let key {
            request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        }
        
        let params: [String: Any] = ["model": "gpt-3.5-turbo", "messages": [["role": "system", "content": "hello"]]]
        request.httpBody = try JSONSerialization.data(withJSONObject: params)
        let _ = try await send(request, type: OpenAIResponse.Chat.self)
    }
    
    /// 验证 Whisper 接口
    func verifyWhisper(_ host: String, key: String?) async throws {
        guard let hostURL = URL(string: host) else {
            throw URLError(.badURL)
        }
        
        guard let fileURL = Bundle.main.url(forResource: "hi", withExtension: "m4a") else {
            throw URLError(.fileDoesNotExist)
        }
        
        let url = hostURL.appending(path: "v1/audio/transcriptions")
        var request = URLRequest(url: url)
        if let key {
            request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        }
        
        let boundary = generateBoundary()
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        let body: Data!
        do {
            let params = ["model": "whisper-1"]
            body = try createWhisperBody(boundary: boundary, fileURL: fileURL, params: params)
        } catch {
            throw OpenAIError.unknown(error)
        }
        let (data, response) = try await URLSession.shared.upload(for: request, from: body)
        let _ = try decodeResponse(data: data, response: response, type: OpenAIResponse.Transcription.self)
    }
    
    func summarize(_ msg: String, model: OpenAIChatModel, temperature: Double = 0.4) async throws -> AsyncThrowingStream<String, Error> {
        let url = baseURL.appending(path: "v1/chat/completions")
        var request = buildRequest(url: url)
        
        let params: [String: Any] = ["model": model.name, "stream": true, "temperature": temperature, "messages": [["role": "system", "content": msg]]]
        request.httpBody = try JSONSerialization.data(withJSONObject: params)
        
        let (data, response) = try await URLSession.shared.bytes(for: request)
        
        guard let response = response as? HTTPURLResponse else { throw OpenAIError.badResponse("") }
        guard response.statusCode == 200 else {
            var body = ""
            for try await line in data.lines { body += line }
            let data = body.data(using: .utf8)!
            if let errorReponse = try? JSONDecoder().decode(OpenAIResponse.Error.self, from: data) {
                throw OpenAIError.apiError(response.statusCode, errorReponse)
            }
            throw OpenAIError.badResponse(body)
        }
        
        return AsyncThrowingStream<String, Error> { continuation in
            Task(priority: .userInitiated) {
                do {
                    for try await line in data.lines {
                        guard let message = parseChunk(line) else { continue}
                        continuation.yield(message)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
                continuation.onTermination = { @Sendable status in
                    XLog.info("Stream terminated with status: \(status)", source: "OpenAI")
                }
            }
        }
    }
    
    /// 转写音频文件
    /// - Parameter fileURL: 文件路径
    func transcribe(_ fileURL: URL, lang: TranscriptionLang = .auto) async throws -> OpenAIResponse.Transcription {
        let url = baseURL.appending(path: "v1/audio/transcriptions")
        var request = buildRequest(url: url)
        let boundary = generateBoundary()
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let body: Data!
        do {
            var params = ["model": "whisper-1"]
            if lang != .auto {
                params["language"] = lang.whisperLangCode
                if let prompt = lang.whisperPrompt {
                    params["prompt"] = prompt
                }
            }
            XLog.debug("Whisper params = \(params)", source: TAG)
            body = try createWhisperBody(boundary: boundary, fileURL: fileURL, params: params)
        } catch {
            throw OpenAIError.unknown(error)
        }
        
        let (data, response) = try await URLSession.shared.upload(for: request, from: body)
        return try decodeResponse(data: data, response: response, type: OpenAIResponse.Transcription.self)
    }
    
    // MARK: - Private Methods
    
    private func generateRequestId() -> String {
        let ts = String(Int(Date().timeIntervalSince1970))
        return "\(ts)-\(UUID().uuidString.lowercased())"
    }
    
    private func generateHMAC(_ message: String) -> String {
        let keyData = ArkanaKeys.Global().hMAC_KEY.data(using: .utf8)!
        let key = SymmetricKey(data: keyData)
        let data = message.data(using: .utf8)!
        let hmac = HMAC<SHA256>.authenticationCode(for: data, using: key)
        let hmacBase64 = Data(hmac).base64EncodedString()
        return hmacBase64
    }
    
    private func generateBoundary() -> String {
        "Boundary-\(UUID().uuidString)"
    }
    
    private func buildRequest(url: URL, method: String = "POST") -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        XLog.debug("\(method) \(url)", source: TAG)
        
        if let key = apiKey {
            XLog.debug("\t|- API KEY = \(key.prefix(10))...", source: TAG)
            request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        }
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(Constants.user_agent, forHTTPHeaderField: "User-Agent")
        
        if requiresHMAC {
            let id = generateRequestId()
            let hmac = generateHMAC(id)
            request.setValue(id, forHTTPHeaderField: "x-alog-request-id")
            request.setValue(hmac, forHTTPHeaderField: "x-alog-hmac")
            XLog.debug("\t|- request_id = \(id), hmac = \(hmac)", source: TAG)
        }
        
        return request
    }
    
    private func createWhisperBody(boundary: String, fileURL: URL, params: [String: String]) throws -> Data {
        var body = Data()
        let filename = fileURL.lastPathComponent
        let data = try Data(contentsOf: fileURL)
        let mimetype = "audio/x-m4a"
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n".data(using: .utf8)!)
        for (k, v) in params {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(k)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(v)\r\n".data(using: .utf8)!)
        }
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        return body
    }
    
    private func parseChunk(_ line: String) -> String? {
        let components = line.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: true)
        guard components.count == 2, components[0] == "data" else { return nil }
        let message = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
        if message == "[DONE]" { return "\n" }
        let chunk = try? JSONDecoder().decode(OpenAIResponse.Chunk.self, from: message.data(using: .utf8)!)
        return chunk?.choices.first?.delta.content
    }
    
    private func send<T: Decodable>(_ request: URLRequest, type: T.Type) async throws -> T {
        let (data, response) =  try await URLSession.shared.data(for: request)
        return try decodeResponse(data: data, response: response, type: T.self)
    }
    
    private func decodeResponse<T: Decodable>(data: Data, response: URLResponse, type: T.Type) throws -> T {
        let body = String(data: data, encoding: .utf8) ?? ""
        
        XLog.debug("⬇ \(body)", source: TAG)
        
        guard let response = response as? HTTPURLResponse else {
            throw OpenAIError.badResponse(body)
        }
        
        if response.statusCode != 200 {
            guard let errorReponse = try? JSONDecoder().decode(OpenAIResponse.Error.self, from: data) else {
                throw OpenAIError.badResponse(body)
            }
            throw OpenAIError.apiError(response.statusCode, errorReponse)
        }
        
        do {
            let decoder = JSONDecoder()
            let decodedData = try decoder.decode(T.self, from: data)
            return decodedData
        } catch let error as DecodingError{
            throw OpenAIError.decoding(error)
        } catch {
            throw OpenAIError.unknown(error)
        }
    }
}
