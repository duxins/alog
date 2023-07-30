//
//  PremiumView.swift
//  ALog
//
//  Created by Xin Du on 2023/07/29.
//

import SwiftUI
import ConfettiSwiftUI

struct PremiumView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var iap: IAPManager
    @Environment(\.dismiss) var dismiss
    
    @State private var counter = 0
    
    var body: some View {
        ZStack {
            VStack(spacing: 50){
                Spacer().frame(height: 10)
                titleView()
                    .confettiCannon(counter: $counter, num: 120, openingAngle: Angle(degrees: 0), closingAngle: Angle(degrees: 360), radius: 240)
                featuresTable()
                Spacer()
            }
            
            if !appState.isPremium {
                purchaseButtonAndFooter
            }
        }
        .padding(.horizontal, 30)
        .onChange(of: iap.state) { newValue in
            if case .purchased = newValue {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                counter += 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    dismiss()
                }
            }
        }
    }
    
    private func titleView() -> some View {
        VStack(spacing: 20) {
            Group {
                Text("ALog ") + Text(L(.premium).capitalized).foregroundColor(.orange)
            }
            .font(.system(size: 35, weight: .black, design: .monospaced))
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(L(.premium_one_time_upgrade).uppercased())
                .font(.title3)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.secondary)
        }
    }
    
    private var purchaseButtonAndFooter: some View {
        VStack(spacing: 20) {
            Spacer()
            FeedbackButton {
                buyPremium()
            } label: {
                if iap.state == .loading || iap.state == .purchasing {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text(purchaseButtonTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 50)
            .background(.blue)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .disabled(!iap.canPurchase)
            
            Button {
                dismiss()
            } label: {
                Text(L(.not_now))
                    .font(.callout)
                    .foregroundColor(.secondary)
            }
            
            footer()
                .padding(.vertical, 20)
        }
    }
    
    private var purchaseButtonTitle: String {
        if case .loaded(let product) = iap.state {
            return L(.premium_go_premium, product.localizedPrice)
        }
        
        return L(.premium_upgrade_to_premium)
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
                feature(L(.premium_custom_server))
                checkMark()
            }
            GridRow {
                feature(L(.premium_summary_num))
                highlightText(L(.unlimited))
            }
            GridRow {
                feature(L(.premium_prompt_num))
                highlightText(L(.unlimited))
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private func footer() -> some View {
        VStack(spacing: 10) {
            HStack(spacing: 5) {
                Button(L(.premium_restore_purchase)){
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
            .font(.headline)
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
