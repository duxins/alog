//
//  AboutView.swift
//  ALog
//
//  Created by Xin Du on 2023/07/22.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        Form {
            Section {
            } header: {
                VStack(spacing: 0) {
                    Image("logo")
                        .resizable()
                        .frame(width: 120, height: 120)
                    Text(L(.app_name))
                    .font(.system(.largeTitle, design: .monospaced))
                    .padding(.bottom, 20)
                    
                    Text("by " + L(.company))
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 30)
            } footer: {
                Spacer()
                    .frame(height: 20)
            }
            .headerProminence(.increased)
            
            Section {
                socialRow("Twitter", icon: "icon_twitter", color: .blue, url: Constants.Contact.twitter)
                socialRow("Github", icon: "icon_github", color: .primary, url: Constants.Contact.github)
            }
            
            Section {
                creditRow(L(.credit_onenewbite_name), url: L(.credit_onenewbite_url))
                creditRow(L(.credit_goldengrape_name),url: L(.credit_goldengrape_url))
                creditRow("Cʜᴇɴɢ", url: "https://twitter.com/scomper")
                creditRow("Yifan Men", url: "https://github.com/menyf")
            } header: {
                Text("Credits")
            }
            
            
            Section {
                creditRow("MingCute Icon", url: "https://www.mingcute.com")
                creditRow("KeychainAccess", url: "https://github.com/kishikawakatsumi/KeychainAccess")
                creditRow("ConfettiSwiftUI", url: "https://github.com/simibac/ConfettiSwiftUI")
                creditRow("DSWaveformImage", url: "https://github.com/dmrschmidt/DSWaveformImage")
                creditRow("CSV.swift", url: "https://github.com/yaslab/CSV.swift")
                creditRow("TPPDF", url: "https://github.com/techprimate/TPPDF")
            } header: {
                Text("Libraries")
            }
            
        }
        .navigationTitle(L(.about))
        .background(Color.app_bg)
    }
    
    @ViewBuilder
    private func socialRow(_ title: String, icon: String, color: Color, url: String) -> some View {
        Button {
            UIApplication.shared.open(URL(string: url)!)
        } label: {
            HStack(spacing: 15) {
                Image(icon)
                    .resizable()
                    .foregroundColor(color)
                    .frame(width: 24, height: 24)
                VStack(alignment: .leading, spacing: 5) {
                    Text(title)
                    Text(url.replacingOccurrences(of: "https://", with: ""))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "arrow.up.right")
                    .foregroundColor(.init(uiColor: .tertiaryLabel))
            }
        }
    }
    
    @ViewBuilder
    private func creditRow(_ name: String, desc: String? = nil, url: String) -> some View {
        Button {
            UIApplication.shared.open(URL(string: url)!)
        } label: {
            HStack(spacing: 15) {
                VStack(alignment: .leading, spacing: 12) {
                    Text(name)
                    if let desc {
                        Text(desc)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                Image(systemName: "arrow.up.right")
                    .foregroundColor(.init(uiColor: .tertiaryLabel))
            }
            .padding(.vertical, 3)
        }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
            .preferredColorScheme(.dark)
    }
}
