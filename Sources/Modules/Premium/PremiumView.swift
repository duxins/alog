//
//  PremiumView.swift
//  ALog
//
//  Created by Xin Du on 2023/07/29.
//

import SwiftUI

struct PremiumView: View {
    @EnvironmentObject var iap: IAPManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            VStack(spacing: 50){
                Spacer().frame(height: 10)
                titleView()
                featuresTable()
                Spacer()
            }
            
            VStack(spacing: 20) {
                Spacer()
                Button {
                    buyPremium()
                } label: {
                    if iap.state == .loading || iap.state == .purchasing {
                        ProgressView()
                    } else {
                        Text(purchaseButtonTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity)
                .background(.blue)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .disabled(!iap.canPurchase)
                
                Button {
                    dismiss()
                } label: {
                    Text("Not Now")
                        .font(.callout)
                        .foregroundColor(.secondary)
                }
                
                footer()
                    .padding(.vertical, 10)
            }
        }
        .padding(.horizontal, 30)
    }
    
    private func titleView() -> some View {
        VStack(spacing: 20) {
            Group {
                Text("ALog ") + Text("Premium").foregroundColor(.orange)
            }
            .font(.system(size: 35, weight: .black, design: .monospaced))
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("A ONE-TIME UPGRADE")
                .font(.title3)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.secondary)
        }
    }
    
    private var purchaseButtonTitle: String {
        if case .loaded(let product) = iap.state {
            return "Go Premium: \(product.localizedPrice)"
        }
        
        return "Upgrade to Premium"
    }
    
    private func buyPremium() {
        guard case .loaded(let product) = iap.state else {
            return
        }
        iap.buy(product: product)
    }
    
    private func restorePremium() {
        iap.restore()
    }
    
    private func featuresTable() -> some View {
        Grid(verticalSpacing: 20) {
            GridRow {
                feature("Unlimited Summaries")
                checkMark()
            }
            GridRow {
                feature("Unlimited Whisper transcription")
                checkMark()
            }
            GridRow {
                feature("Custom server")
                checkMark()
            }
            GridRow {
                feature("Daily character limit")
                highlightText("20,000")
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private func footer() -> some View {
        VStack(spacing: 10) {
            HStack(spacing: 5) {
                Button("Restore Purchase"){
                    restorePremium()
                }
                Text("・")
                Link(L(.privacy_policy), destination: URL(string: Constants.Legal.privacy_policy_url)!)
                Text("・")
                Link(L(.terms_of_use), destination: URL(string: Constants.Legal.terms_url)!)
            }
            .font(.footnote)
            .foregroundColor(.secondary)
        }
    }
    
    private func feature(_ title: String) -> some View {
        Text(title)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func checkMark() -> some View {
        Image(systemName: "checkmark.circle.fill")
            .font(.footnote)
            .foregroundColor(.green)
    }
    
    private func highlightText(_ text: String) -> some View {
        Text(text)
            .font(.footnote)
            .foregroundColor(.secondary)
    }
    
}

struct PremiumView_Previews: PreviewProvider {
    static var previews: some View {
        PremiumView()
            .preferredColorScheme(.dark)
            .environmentObject(IAPManager())
    }
}
