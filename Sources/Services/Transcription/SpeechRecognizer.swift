//
//  SpeechRecognizer.swift
//  ALog
//
//  Created by Xin Du on 2023/07/16.
//

import Foundation
import Speech
import XLog

enum SpeechRecognizerError: Error {
    case unknown
}

class SpeechRecognizer {
    static let shared = SpeechRecognizer()
    private init() {}
    
    func transcribe(_ fileURL: URL, lang: TranscriptionLang) async throws -> String {
        let recognizer = createSpeechRecognizer(with: lang.localeIdentifier)
        let request = SFSpeechURLRecognitionRequest(url: fileURL)
        
        return try await withCheckedThrowingContinuation { continuation in
            recognizer?.recognitionTask(with: request) { result, error in
                guard error == nil else {
                    continuation.resume(throwing: error!)
                    return
                }
                
                if let result = result {
                    XLog.debug("⚬ \(result.bestTranscription.formattedString)", source: "Speech")
                    if result.isFinal {
                        let text = result.bestTranscription.formattedString
                        XLog.info("✔︎ \(text)", source: "Speech")
                        continuation.resume(returning: text)
                    }
                } else {
                    continuation.resume(throwing: SpeechRecognizerError.unknown)
                }
            }
        }
    }
    
    private func createSpeechRecognizer(with localeIdentifier: String?) -> SFSpeechRecognizer? {
        if let localeIdentifier {
            let locale = Locale(identifier: localeIdentifier)
            return SFSpeechRecognizer(locale: locale)
//            return SFSpeechRecognizer()
        } else {
            return SFSpeechRecognizer()
        }
    }
}
