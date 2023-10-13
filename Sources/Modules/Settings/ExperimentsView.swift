//
//  ExperimentsView.swift
//  ALog
//
//  Created by Xin Du on 2023/10/09.
//

import SwiftUI

struct ExperimentsView: View {
    @EnvironmentObject var config: Config
    
    @FocusState private var whisperPromptFocused: Bool
    
    var body: some View {
        Form {
            whisperSection
            autoStopSection
        }
        .navigationTitle(L(.settings_experimental_features))
    }
    
    
    @ViewBuilder
    /// 自定义提示词
    private var whisperSection: some View {
        Section {
            MyToggle(isOn: $config.customWhisperPromptEnabled) {
                Text(L(.settings_custom_whisper_prompt_enabled))
            }
            
            if config.customWhisperPromptEnabled {
                TextEditor(text: $config.customWhisperPrompt)
                    .focused($whisperPromptFocused)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .foregroundColor(.secondary)
                    .frame(minHeight: 80)
            }
        } footer: {
            if config.customWhisperPromptEnabled {
                Text(L(.settings_custom_whisper_desc))
            } else {
                Text(" ")
            }
        }
        .onChange(of: config.customWhisperPromptEnabled) { newValue in
            if newValue == true {
                whisperPromptFocused = true
            }
        }
    }
    
    @ViewBuilder
    /// 自动停止录音
    private var autoStopSection: some View {
        Section {
            MyToggle(isOn: $config.featureAutoStop) {
                Text(L(.settings_feature_auto_stop))
            }
        } footer: {
            Text(L(.settings_feature_auto_stop_desc))
        }
    }
}

struct ExperimentsView_Previews: PreviewProvider {
    static var previews: some View {
        ExperimentsView()
            .environmentObject(Config.shared)
    }
}
