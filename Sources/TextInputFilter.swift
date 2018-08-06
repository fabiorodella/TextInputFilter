//
//  TextInputFilter.swift
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

/// Possible results that can be returned from a TextInputFilter in response to an input
///
/// - accept: the input should be accepted as-is
/// - reject: the input should be rejected
/// - transform: the input should be rejected by the target, but a transformed version should then be set
public enum TextInputFilterResult {
    case accept
    case reject
    case transform(String)
}

/// Protocol to be adopted by entities that can filter input
public protocol TextInputFilter {
    
    /// Given an input, return a result indicating how that change should be applied
    ///
    /// - Parameters:
    ///   - change: the string containing the change text
    ///   - original: the original text before the change
    ///   - range: the range in the original text that will be replaced by the change
    ///   - changed: convenience value containing the original text with the change already applied
    /// - Returns: the result for this change
    func result(for change: String, appliedTo original: String, replacingRange range: Range<String.Index>, changed: String) -> TextInputFilterResult
}
