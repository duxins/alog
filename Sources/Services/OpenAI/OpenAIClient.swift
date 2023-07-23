//
//  OpenAIClient.swift
//  ALog
//
//  Created by Xin Du on 2023/07/14.
//

import Foundation
import XLog

struct OpenAIResponse {
    struct Error: Codable {
        let error: ErrorBody
        struct ErrorBody: Codable {
            let message: String
            let code: String?
        }
    }
    
    struct Subscription: Codable {
        let object: String
        let has_payment_method: Bool
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
    
    let baseURL = URL(string: "https://api.openai.com/")!
    
    
    /// 验证 API KEY
    /// - Parameter key: API KEY
    func verify(_ key: String) async throws -> OpenAIResponse.Subscription {
        let url = baseURL.appending(path: "dashboard/billing/subscription")
        var request = URLRequest(url: url)
        request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        let sub = try await send(request, type: OpenAIResponse.Subscription.self)
        return sub
    }
    
    func summarize(_ msg: String) async throws -> AsyncThrowingStream<String, Error> {
        let url = baseURL.appending(path: "v1/chat/completions")
        let model = Config.shared.aiModel.name
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let params: [String: Any] = ["model": model, "stream": true, "temperature": 0.4, "messages": [["role": "system", "content": msg]]]
        request.httpBody = try JSONSerialization.data(withJSONObject: params)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(Config.shared.apiKey)", forHTTPHeaderField: "Authorization")
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
                    XLog.info("Stream terminated: \(status)", source: "OpenAI")
                }
            }
        }
    }
    
    func parseChunk(_ line: String) -> String? {
        let components = line.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: true)
        guard components.count == 2, components[0] == "data" else { return nil }
        let message = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
        if message == "[DONE]" { return "\n" }
        let chunk = try! JSONDecoder().decode(OpenAIResponse.Chunk.self, from: message.data(using: .utf8)!)
        return chunk.choices.first?.delta.content
    }
    
    /// 转写音频文件
    /// - Parameter fileURL: 文件路径
    func transcribe(_ fileURL: URL) async throws -> OpenAIResponse.Transcription {
        let url = baseURL.appending(path: "v1/audio/transcriptions")
        var request = URLRequest(url: url)
        request.setValue("Bearer \(Config.shared.apiKey)", forHTTPHeaderField: "Authorization")
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let body: Data!
        do {
            var params = ["model": "whisper-1"]
            if Config.shared.transLang != .auto {
                params["language"] = Config.shared.transLang.whisperLangCode
                if let prompt = Config.shared.transLang.whisperPrompt {
                    params["prompt"] = prompt
                }
            }
            body = try createWhisperBody(boundary: boundary, fileURL: fileURL, params: params)
        } catch {
            throw OpenAIError.unknown(error)
        }
        
        let (data, response) = try await URLSession.shared.upload(for: request, from: body)
        return try decodeResponse(data: data, response: response, type: OpenAIResponse.Transcription.self)
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
    
    private func send<T: Decodable>(_ request: URLRequest, type: T.Type) async throws -> T {
        XLog.debug("➡ \(request)", source: TAG)
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
