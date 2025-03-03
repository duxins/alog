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
                MyToggle(isOn: Binding(
                    get: { config.autoStartOnStartup == StartupOption.record },
                    set: { config.autoStartOnStartup = $0 ? StartupOption.record : "" }
                )) {
                    Text(L(.auto_record_on_startup))
                }
                
                MyToggle(isOn: Binding(
                    get: { config.autoStartOnStartup == StartupOption.createNote },
                    set: { config.autoStartOnStartup = $0 ? StartupOption.createNote : ""}
                )) {
                    Text(L(.auto_create_note_on_startup))
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
