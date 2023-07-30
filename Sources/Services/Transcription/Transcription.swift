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

struct Transcription {
    
    private let TAG = "Trans"
    
    let hallucinationList: Set<String> = [
        "请不吝点赞 订阅 转发 打赏支持明镜与点点栏目",
        "請不吝點贊訂閱轉發打賞支持明鏡與點點欄目",
        "字幕由Amara.org社区提供",
        "小編字幕由Amara.org社區提供",
        "字幕by索兰娅",
        "由 Amara.org 社群提供的字幕"
    ]
    
    func transcribe(voiceURL: URL, provider: TranscriptionProvider, lang: TranscriptionLang) async throws -> String {
        XLog.info("Transcribe \(voiceURL.lastPathComponent) using \(provider). lang = \(lang.rawValue)", source: TAG)
        if provider == .apple {
            let text = try await SpeechRecognizer.shared.transcribe(voiceURL, lang: lang)
            return text
        } else if provider == .openai {
            let text = try await OpenAIClient.shared.transcribe(voiceURL, lang: lang).text
            if hallucinationList.contains(text) {
                XLog.info("😵‍💫 skip '\(text)'", source: TAG)
                return ""
            }
            return text
        }
        return ""
    }
    
}
