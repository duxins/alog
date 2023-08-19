//
//  ShareViewController.swift
//  ALog
//
//  Created by Xin Du on 2023/08/19.
//

import SwiftUI

// Taken from https://stackoverflow.com/questions/69693871/how-to-open-share-sheet-from-presented-sheet
struct SharingViewController: UIViewControllerRepresentable {
    @Binding var isPresenting: Bool
    var content: () -> UIViewController

    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if isPresenting {
            uiViewController.present(content(), animated: true, completion: nil)
        }
    }
}
