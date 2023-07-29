//
//  SKProduct+Extensions.swift
//  ALog
//
//  Created by Xin Du on 2023/07/29.
//

import Foundation
import StoreKit

extension SKProduct {
    var localizedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = priceLocale
        return formatter.string(from: price)!
    }
}
