//
//  MyTextView.swift
//  ALog
//
//  Created by Xin Du on 2023/07/19.
//

import SwiftUI

struct MyTextView: View {
    @State private var height: CGFloat = .zero
    @Binding var text: String
    
    let minHeight: CGFloat
    
    init(text: Binding<String>, minHeight: CGFloat = .zero) {
        self._text = text
        self.minHeight = minHeight
    }
    
    var body: some View {
        GeometryReader { geo in
            TextViewInternal(text: $text, width: geo.size.width, height: $height, minHeight: minHeight)
        }
        .frame(height: height)
    }
    
    private struct TextViewInternal: UIViewRepresentable {
        typealias Context = UIViewRepresentableContext<TextViewInternal>
        
        let width: CGFloat
        let minHeight: CGFloat
        @Binding var text: String
        @Binding var height: CGFloat
        
        init(text: Binding<String>, width: CGFloat, height: Binding<CGFloat>, minHeight: CGFloat) {
            self._text = text
            self.width = width
            self._height = height
            self.minHeight = minHeight
        }
        
        func makeUIView(context: Context) -> UIView {
            let textView = UITextView()
            textView.font = .preferredFont(forTextStyle: .body)
            textView.delegate = context.coordinator
            textView.autocapitalizationType = .none
            textView.autocorrectionType = .no
            textView.isScrollEnabled = false
            textView.backgroundColor = .clear
            
            let view = UIView()
            view.addSubview(textView)
            
            return view
        }
        
        func updateUIView(_ view: UIView, context: Context) {
            let textView = view.subviews.first! as! UITextView
            
            if !context.coordinator.isEditing {
                textView.text = text
            }
            
            let bounds = CGSize(width: width, height: height)
            
            DispatchQueue.main.async {
                let h = textView.sizeThatFits(bounds).height
//                height = textView.sizeThatFits(bounds).height
                height = max(h, minHeight)
                let size = CGSize(width: width, height: height)
                view.frame.size = size
                textView.frame.size = size
            }
            
        }
        
        func makeCoordinator() -> Coordinator {
            Coordinator(text: $text)
        }
        
        class Coordinator: NSObject, UITextViewDelegate {
            var text: Binding<String>
            var isEditing: Bool = false
            
            init(text: Binding<String>) {
                self.text = text
            }
            
            func textViewDidChange(_ textView: UITextView) {
                self.text.wrappedValue = textView.text
            }
            
            func textViewDidBeginEditing(_ textView: UITextView) {
                isEditing = true
            }
            
            func textViewDidEndEditing(_ textView: UITextView) {
                isEditing = false
            }
        }
    }
}
