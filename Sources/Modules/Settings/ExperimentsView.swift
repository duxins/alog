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
            
            Section {
                MyToggle(isOn: $config.holdToRecordEnabled) {
                    Text(L(.hold_to_record))
                }
            }
        }
        .navigationTitle(L(.settings_experimental_features))
        .onChange(of: config.customWhisperPromptEnabled) { newValue in
            if newValue == true {
                whisperPromptFocused = true
            }
        }
    }
}

struct ExperimentsView_Previews: PreviewProvider {
    static var previews: some View {
        ExperimentsView()
            .environmentObject(Config.shared)
    }
}
