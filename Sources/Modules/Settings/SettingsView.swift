//
//  SettingsView.swift
//  ALog
//
//  Created by Xin Du on 2023/07/10.
//

import SwiftUI
import XLang

struct SettingsView: View {
    @EnvironmentObject var config: Config
    @EnvironmentObject var appState: AppState
    
    @State private var showTransWarning = false {
        didSet {
            if showTransWarning {
                transWarningDisplayed = true
            }
        }
    }
    @AppStorage("trans_privacy_warning_displayed") var transWarningDisplayed = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    sectionGeneral
                    sectionTranscription
                    sectionSummarization
                    sectionOpenAI
                    sectionInfo
                }
            }
            .navigationTitle(L(.settings_title))
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: config.transEnabled) { newValue in
                if newValue && transWarningDisplayed == false {
                    showTransWarning = true
                }
            }
        }
    }
    
    @ViewBuilder
    private var sectionGeneral: some View {
        Section {
            Picker(selection: $config.dayStartTime) {
                ForEach(0..<9) { n in
                    Text("0\(n):00")
                        .tag(n)
                }
            } label: {
                Text(L(.settings_day_starts_at))
            }
            
            Picker(selection: $appState.language) {
                ForEach(Language.supported, id: \.self) { lang in
                    Text(lang.displayName)
                        .tag(lang)
                }
            } label: {
                Text(L(.settings_app_language))
            }
        } header: {
            Text(L(.settings_general))
        }
    }
    
    @ViewBuilder
    private var sectionTranscription: some View {
        Section {
            MyToggle(isOn: $config.transEnabled) {
                Text(L(.enable))
            }
            
            if config.transEnabled {
                Picker(selection: $config.transLang) {
                    ForEach(TranscriptionLang.allCases, id: \.self) { item in
                        Text(item.displayName)
                    }
                } label: {
                    Text(L(.settings_trans_lang))
                }
                
                Picker(selection: $config.transProvider) {
                    ForEach(TranscriptionProvider.allCases, id: \.self) { item in
                        Text(item.displayName)
                    }
                } label: {
                    Text(L(.settings_trans_provider))
                }
            }
        } header: {
            Text(L(.settings_trans))
        } footer: {
            if config.transEnabled {
                if config.transProvider == .apple {
                    Text(L(.trans_provider_apple_notice))
                }
                
                if config.transProvider == .openai  && !config.isApiKeySet {
                    Text(L(.trans_provider_opanai_api_key_warning))
                }
            }
        }
        .alert(isPresented: $showTransWarning) {
            Alert(title: Text(L(.settings_trans_privacy_warning)), dismissButton: nil)
        }
    }
    
    @ViewBuilder
    private var sectionSummarization: some View {
        Section {
            MyToggle(isOn: $config.sumEnabled) {
                Text(L(.enable))
            }
            
            if config.sumEnabled {
                Picker(selection: $config.sumProvider) {
                    ForEach(SummarizationProvider.allCases, id: \.self) {
                        Text($0.displayName)
                    }
                } label: {
                    Text(L(.settings_sum_provider))
                }
                .disabled(!config.sumEnabled)
                
                if config.sumProvider == .openai {
                    Picker(selection: $config.aiModel) {
                        ForEach(OpenAIChatModel.allCases, id: \.self) {
                            Text($0.displayName)
                        }
                    } label: {
                        Text(L(.settings_sum_ai_model))
                    }
                }
                
                NavigationLink {
                    PromptsView()
                } label: {
                    Text(L(.settings_sum_prompts))
                }
            }
        } header: {
            Text(L(.settings_sum))
        } footer: {
            if config.sumEnabled && config.sumProvider == .openai && !config.isApiKeySet {
                Text(L(.sum_opanai_api_key_warning))
            }
        }
    }
    
    @ViewBuilder
    private var sectionOpenAI: some View {
        Section {
            NavigationLink(destination: OpenAISettingsView().environmentObject(config)) {
                Text(L(.settings_openai_settings))
            }
        } header: {
            Text(L(.settings_openai))
        }
    }
    
    @ViewBuilder
    private var sectionInfo: some View {
        Section {
            
            NavigationLink(destination: AboutView()) {
                Text(L(.about_app))
            }
            
            HStack {
                Text(L(.version))
                Spacer()
                HStack {
                    Group {
                        Text("v\(AppInfo.appVersion)")
                            .foregroundColor(.secondary)
                        Text("(\(AppInfo.gitHash.isEmpty ? AppInfo.buildVersion : AppInfo.gitHash))")
                            .foregroundColor(Color(uiColor: .tertiaryLabel))
                    }
                    .font(.system(.footnote, design: .monospaced))
                }
            }
        } footer: {
            VStack(spacing: 10) {
                Link(L(.source_code), destination: URL(string: Constants.Legal.source_url)!)
                HStack(spacing: 5) {
                    Link(L(.privacy_policy), destination: URL(string: Constants.Legal.privacy_policy_url)!)
                    Text("・")
                    Link(L(.terms_of_use), destination: URL(string: Constants.Legal.terms_url)!)
                }
            }
            .foregroundColor(.secondary)
            .font(.caption)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
