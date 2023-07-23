//
//  Transcription.swift
//  ALog
//
//  Created by Xin Du on 2023/07/15.
//

import Foundation
import XLog

enum TranscriptionError: Error {
    
}

class Transcription {
    let hallucinationList = [
        "请不吝点赞 订阅 转发 打赏支持明镜与点点栏目",
        "字幕由Amara.org社区提供",
        "由 Amara.org 社群提供的字幕"
    ]
    
    func transcribe(voiceURL: URL, provider: TranscriptionProvider, lang: TranscriptionLang) async throws -> String {
        if provider == .apple {
            let text = try await SpeechRecognizer.shared.transcribe(voiceURL, lang: lang)
            return text
        } else if provider == .openai {
            let text = try await OpenAIClient.shared.transcribe(voiceURL).text
            if hallucinationList.contains(text) {
                XLog.info("😵‍💫 skip '\(text)'", source: "Trans")
                return ""
            }
            return text
        }
        return ""
    }
    
    
}
