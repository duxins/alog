//
//  ShareHelper.swift
//  ALog
//
//  Created by Xin Du on 2023/07/20.
//

import Foundation
import UIKit

class ShareHelper {
    static func share(items: [Any]){
        let viewController = UIActivityViewController(activityItems: items, applicationActivities: nil)

        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        
        window?.rootViewController?.present(viewController, animated: true)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            viewController.popoverPresentationController?.sourceView = window
            viewController.popoverPresentationController?.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2.1 , y: UIScreen.main.bounds.height / 1.3, width: 200, height: 200)
        }
    }
}
