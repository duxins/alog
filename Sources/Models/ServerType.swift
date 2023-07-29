//
//  ServerType.swift
//  ALog
//
//  Created by Xin Du on 2023/07/29.
//

import Foundation

enum ServerType: String, CaseIterable {
    case app
    case custom
    
    var displayName: String {
        switch self {
        case .app: return L(.server_default)
        case .custom: return L(.server_custom)
        }
    }
}
