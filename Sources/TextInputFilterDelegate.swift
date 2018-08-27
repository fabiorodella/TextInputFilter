//
//  TextInputFilterDelegate.swift
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

import Foundation

enum TextInputFilterDelegateAssociatedKeys {
    
    static var filterDelegate = "info.rodels.textInputFilter.filterDelegate"
    static var originalDelegateObservation = "info.rodels.textInputFilter.originalDelegateObservation"
}

protocol TextInputFilterAssociatedObjects: AnyObject {
    
    associatedtype TextInputFilterDelegateType: AnyObject
    
    var textInputFilter_filterDelegate: TextInputFilterDelegateType? { get set }
    var textInputFilter_originalDelegateObservation: Any? { get set }
}

extension TextInputFilterAssociatedObjects where Self: NSObject {
    
    var textInputFilter_filterDelegate: TextInputFilterDelegateType? {
        get {
            return objc_getAssociatedObject(self, &TextInputFilterDelegateAssociatedKeys.filterDelegate) as? TextInputFilterDelegateType
        }
        set {
            objc_setAssociatedObject(self, &TextInputFilterDelegateAssociatedKeys.filterDelegate, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    var textInputFilter_originalDelegateObservation: Any? {
        get {
            return objc_getAssociatedObject(self, &TextInputFilterDelegateAssociatedKeys.originalDelegateObservation)
        }
        set {
            objc_setAssociatedObject(self, &TextInputFilterDelegateAssociatedKeys.originalDelegateObservation, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
}

protocol TextInputFilterDelegate {
    
    var inputFilter: TextInputFilter { get }
    var onChange: ((String) -> ())? { get }
    
    init(inputFilter: TextInputFilter, onChange: ((String) -> ())?)
    
    func applyFilter(to text: String, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> (Bool, String?)
}

extension TextInputFilterDelegate {
    
    func applyFilter(to text: String, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> (Bool, String?) {
        let changeRange = Range(range, in: text)!
        let changed = text.replacingCharacters(in: changeRange, with: string)
        let result = inputFilter.result(for: string, appliedTo: text, replacingRange: changeRange, changed: changed)
        switch result {
        case .transform(let changed):
            onChange?(changed)
            return (false, changed)
        case .accept:
            onChange?(changed)
            return (true, nil)
        case .reject:
            return (false, nil)
        }
    }
}
