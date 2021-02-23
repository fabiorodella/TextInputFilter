//
//  UITextView+TextInputFilter.swift
//  TextInputFilter
//
//  Created by Fabio Rodella on 05/08/18.
//  Copyright © 2018 Rodels. All rights reserved.
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in
//    all copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//    THE SOFTWARE.

import UIKit

public extension UITextView {
    
    /// If a text input filter is set, returns the original delegate for this text view
    var originalDelegate: UITextViewDelegate? {
        return textInputFilter_filterDelegate?.actualDelegate
    }
    
    /// Sets an input filter for this text view, with an optional closure that will be called for every change that
    /// is applied (transformed or otherwise). Please note that due to the way that the text view delegate behaves,
    /// the actual text set in the text view might not have changed yet by the time `onChange` is called, so you
    /// should always rely on the closure parameter to know the current text.
    ///
    /// The input filter will intercept the `textView(_:shouldChangeTextIn:replacementText:)` delegate method,
    /// but any other delegate methods will be forwarded to the original text view delegate (even if the delegate is
    /// set after the call to this).
    ///
    /// - Parameters:
    ///   - inputFilter: the input filter to set, or nil to remove the current input filter
    ///   - onChange: closure caleed for every actual change. If `inputFilter` is nil, this has no effect
    func setInputFilter(_ inputFilter: TextInputFilter?, onChange: ((String) -> ())? = nil) {
        guard let inputFilter = inputFilter else {
            textInputFilter_originalDelegateObservation = nil
            delegate = textInputFilter_filterDelegate?.actualDelegate
            textInputFilter_filterDelegate = nil
            return
        }
        
        let inputFilterDelegate = TextInputFilterTextViewDelegate(inputFilter: inputFilter, onChange: onChange)
        inputFilterDelegate.actualDelegate = delegate
        textInputFilter_filterDelegate = inputFilterDelegate
        
        delegate = inputFilterDelegate
        
        if textInputFilter_originalDelegateObservation == nil {
            let observation = observe(\.delegate) { textField, _ in
                guard textField.delegate !== textField.textInputFilter_filterDelegate else {
                    return
                }
                textField.textInputFilter_filterDelegate?.actualDelegate = textField.delegate
                textField.delegate = textField.textInputFilter_filterDelegate
            }
            if #available(iOS 11.0, *) {
                textInputFilter_originalDelegateObservation = observation
            } else {
                textInputFilter_originalDelegateObservation = LegacyKeyValueObservationCleanerWrapper(observation: observation, observer: self)
            }
        }
    }
}

extension UITextView: TextInputFilterAssociatedObjects {
    
    typealias TextInputFilterDelegateType = TextInputFilterTextViewDelegate
}

class TextInputFilterTextViewDelegate: NSObject, UITextViewDelegate, TextInputFilterDelegate {
    
    let inputFilter: TextInputFilter
    let onChange: ((String) -> ())?
    
    weak var actualDelegate: UITextViewDelegate?
    
    required init(inputFilter: TextInputFilter, onChange: ((String) -> ())?){
        self.inputFilter = inputFilter
        self.onChange = onChange
        super.init()
    }
    
    override func responds(to aSelector: Selector!) -> Bool {
        if aSelector == #selector(textView(_:shouldChangeTextIn:replacementText:)) {
            return true
        }
        return actualDelegate?.responds(to: aSelector) ?? false
    }
    
    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        return actualDelegate
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let (shouldChange, newText) = applyFilter(to: textView.text!, shouldChangeCharactersIn: range, replacementString: text)
        if let newText = newText {
            textView.text = newText
        }
        return shouldChange
    }
}
