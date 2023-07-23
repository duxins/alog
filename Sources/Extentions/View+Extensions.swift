//
//  View+Extensions.swift
//  ALog
//
//  Created by Xin Du on 2023/07/13.
//

import Foundation
import SwiftUI

extension View {
    func withoutAnimation(action: @escaping () -> Void) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            action()
        }
    }
}
