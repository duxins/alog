//
//  ErrorHelper.swift
//  ALog
//
//  Created by Xin Du on 2023/07/17.
//

import Foundation

struct ErrorHelper {
    static func desc(_ error: Error) -> String {
        if let err = error as? LocalizedError {
            return err.errorDescription ?? ""
        } else {
            return error.localizedDescription
        }
    }
}
