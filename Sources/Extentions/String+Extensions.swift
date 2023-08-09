//
//  String+Extensions.swift
//  ALog
//
//  Created by Xin Du on 2023/08/09.
//

import Foundation

extension String {
    func formattedHostName() -> String {
        var host = self.replacingOccurrences(of: " ", with: "")
        
        if !host.isEmpty && host.range(of: "^https?://", options: .regularExpression) == nil {
            host = "https://" + host
        }
        
        if !host.isEmpty && host.suffix(1) != "/" {
            host = host + "/"
        }
        
        return host
    }
}
