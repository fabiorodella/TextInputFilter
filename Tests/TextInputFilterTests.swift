//
//  TextInputFilterTests.swift
//  TextInputFilterTests
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

import XCTest
@testable import TextInputFilter

struct UppercaseInputFilter: TextInputFilter {
    
    func result(for change: String, appliedTo original: String, replacingRange range: Range<String.Index>, changed: String) -> TextInputFilterResult {
        return .transform(changed.uppercased())
    }
}

class TextInputFilterTests: XCTestCase {
    
    // MARK: Inner entities
    
    private struct TestFilter: TextInputFilter {
        
        private let lowercaseCharset = CharacterSet(charactersIn: "abcde")
        private let uppercaseCharset = CharacterSet(charactersIn: "ABCDE")
        
        func result(for change: String, appliedTo original: String, replacingRange range: Range<String.Index>, changed: String) -> TextInputFilterResult {
            if change.rangeOfCharacter(from: uppercaseCharset.inverted) == nil {
                return .accept
            } else if change.rangeOfCharacter(from: lowercaseCharset.inverted) == nil {
                return .transform(changed.uppercased())
            } else {
                return .reject
            }
        }
    }
    
    private class TestTextFieldDelegate: NSObject, UITextFieldDelegate {
        
        let callback: () -> ()
        
        init(callback: @escaping () -> ()) {
            self.callback = callback
            super.init()
        }
        
        func textFieldDidBeginEditing(_ textField: UITextField) {
            callback()
        }
    }
    
    private class TestTextViewDelegate: NSObject, UITextViewDelegate {
        
        let callback: () -> ()
        
        init(callback: @escaping () -> ()) {
            self.callback = callback
            super.init()
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            callback()
        }
    }
    
    // MARK: UITextField tests
    
    func testTextFieldAccept() {
        let textField = UITextField(frame: .zero)
        var changed: String?
        textField.setInputFilter(TestFilter(), onChange: { changed = $0 })
        let result = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSRange(location: 0, length: 0), replacementString: "A")
        XCTAssertEqual(result, true, "Delegate should return true to indicate that the entered text should be accepted")
        XCTAssertEqual(textField.text, "", "Text should be empty, since the change would be handled by UITextField itself")
        XCTAssertEqual(changed, "A", "OnChange closure should be called with the applied change")
    }
    
    func testTextFieldTransform() {
        let textField = UITextField(frame: .zero)
        var changed: String?
        textField.setInputFilter(TestFilter(), onChange: { changed = $0 })
        let result = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSRange(location: 0, length: 0), replacementString: "a")
        XCTAssertEqual(result, false, "Delegate should return false to indicate that the entered text should be rejected")
        XCTAssertEqual(textField.text, "A", "Text should contain the input as transformed by the input filter")
        XCTAssertEqual(changed, "A", "OnChange closure should be called with the applied change")
    }
    
    func testTextFieldReject() {
        let textField = UITextField(frame: .zero)
        var changed: String?
        textField.setInputFilter(TestFilter(), onChange: { changed = $0 })
        let result = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSRange(location: 0, length: 0), replacementString: "1")
        XCTAssertEqual(result, false, "Delegate should return false to indicate that the entered text should be rejected")
        XCTAssertEqual(textField.text, "", "Text should be empty, since the change was rejected and no transformation took place")
        XCTAssertNil(changed, "OnChange closure should not be called")
    }
    
    func testTextFieldDelegateSetBeforeFilter() {
        var delegateCalled = false
        let delegate = TestTextFieldDelegate(callback: { delegateCalled = true })
        let textField = UITextField(frame: .zero)
        textField.delegate = delegate
        textField.setInputFilter(TestFilter())
        textField.delegate?.textFieldDidBeginEditing?(textField)
        XCTAssertTrue(delegateCalled, "Original delegate should be called for other methods")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSRange(location: 0, length: 0), replacementString: "a")
        XCTAssertEqual(textField.text, "A", "Text should contain the input as transformed by the input filter")
    }
    
    func testTextFieldDelegateSetAfterFilter() {
        var delegateCalled = false
        let delegate = TestTextFieldDelegate(callback: { delegateCalled = true })
        let textField = UITextField(frame: .zero)
        textField.setInputFilter(TestFilter())
        textField.delegate = delegate
        textField.delegate?.textFieldDidBeginEditing?(textField)
        XCTAssertTrue(delegateCalled, "Original delegate should be called for other methods")
        let _ = textField.delegate?.textField?(textField, shouldChangeCharactersIn: NSRange(location: 0, length: 0), replacementString: "a")
        XCTAssertEqual(textField.text, "A", "Text should contain the input as transformed by the input filter")
    }
    
    func testTextFieldCallOtherDelegateMethod() {
        let textField = UITextField(frame: .zero)
        textField.setInputFilter(TestFilter())
        var result = textField.delegate?.textFieldShouldReturn?(textField)
        XCTAssertNil(result)
        
        let delegate = TestTextFieldDelegate(callback: { })
        textField.delegate = delegate
        result = textField.delegate?.textFieldShouldReturn?(textField)
        XCTAssertNil(result)
    }
    
    func testTextFieldRemoveFilter() {
        let textField = UITextField(frame: .zero)
        textField.setInputFilter(TestFilter())
        XCTAssertNotNil(textField.delegate)
        textField.setInputFilter(nil)
        XCTAssertNil(textField.delegate)
    }
    
    func testTextFieldRemoveFilterRestoreDelegate() {
        let delegate = TestTextFieldDelegate(callback: { })
        let textField = UITextField(frame: .zero)
        textField.delegate = delegate
        textField.setInputFilter(TestFilter())
        XCTAssertFalse(textField.delegate === delegate)
        textField.setInputFilter(nil)
        XCTAssertTrue(textField.delegate === delegate)
    }
    
    // MARK: UITextView tests
    
    func testTextViewAccept() {
        let textView = UITextView(frame: .zero)
        var changed: String?
        textView.setInputFilter(TestFilter(), onChange: { changed = $0 })
        let result = textView.delegate?.textView?(textView, shouldChangeTextIn: NSRange(location: 0, length: 0), replacementText: "A")
        XCTAssertEqual(result, true, "Delegate should return true to indicate that the entered text should be accepted")
        XCTAssertEqual(textView.text, "", "Text should be empty, since the change would be handled by UITextView itself")
        XCTAssertEqual(changed, "A", "OnChange closure should be called with the applied change")
    }
    
    func testTextViewTransform() {
        let textView = UITextView(frame: .zero)
        var changed: String?
        textView.setInputFilter(TestFilter(), onChange: { changed = $0 })
        let result = textView.delegate?.textView?(textView, shouldChangeTextIn: NSRange(location: 0, length: 0), replacementText: "a")
        XCTAssertEqual(result, false, "Delegate should return false to indicate that the entered text should be rejected")
        XCTAssertEqual(textView.text, "A", "Text should contain the input as transformed by the input filter")
        XCTAssertEqual(changed, "A", "OnChange closure should be called with the applied change")
    }
    
    func testTextViewReject() {
        let textView = UITextView(frame: .zero)
        var changed: String?
        textView.setInputFilter(TestFilter(), onChange: { changed = $0 })
        let result = textView.delegate?.textView?(textView, shouldChangeTextIn: NSRange(location: 0, length: 0), replacementText: "1")
        XCTAssertEqual(result, false, "Delegate should return false to indicate that the entered text should be rejected")
        XCTAssertEqual(textView.text, "", "Text should be empty, since the change was rejected and no transformation took place")
        XCTAssertNil(changed, "OnChange closure should not be called")
    }
    
    func testTextViewDelegateSetBeforeFilter() {
        var delegateCalled = false
        let delegate = TestTextViewDelegate(callback: { delegateCalled = true })
        let textView = UITextView(frame: .zero)
        textView.delegate = delegate
        textView.setInputFilter(TestFilter())
        textView.delegate?.textViewDidBeginEditing?(textView)
        XCTAssertTrue(delegateCalled, "Original delegate should be called for other methods")
        let _ = textView.delegate?.textView?(textView, shouldChangeTextIn: NSRange(location: 0, length: 0), replacementText: "a")
        XCTAssertEqual(textView.text, "A", "Text should contain the input as transformed by the input filter")
    }
    
    func testTextViewDelegateSetAfterFilter() {
        var delegateCalled = false
        let delegate = TestTextViewDelegate(callback: { delegateCalled = true })
        let textView = UITextView(frame: .zero)
        textView.setInputFilter(TestFilter())
        textView.delegate = delegate
        textView.delegate?.textViewDidBeginEditing?(textView)
        XCTAssertTrue(delegateCalled, "Original delegate should be called for other methods")
        let _ = textView.delegate?.textView?(textView, shouldChangeTextIn: NSRange(location: 0, length: 0), replacementText: "a")
        XCTAssertEqual(textView.text, "A", "Text should contain the input as transformed by the input filter")
    }
    
    func testTextViewCallOtherDelegateMethod() {
        let textView = UITextView(frame: .zero)
        textView.setInputFilter(TestFilter())
        var result = textView.delegate?.textViewShouldEndEditing?(textView)
        XCTAssertNil(result)
        
        let delegate = TestTextViewDelegate(callback: { })
        textView.delegate = delegate
        result = textView.delegate?.textViewShouldEndEditing?(textView)
        XCTAssertNil(result)
    }
    
    func testTextViewRemoveFilter() {
        let textView = UITextView(frame: .zero)
        textView.setInputFilter(TestFilter())
        XCTAssertNotNil(textView.delegate)
        textView.setInputFilter(nil)
        XCTAssertNil(textView.delegate)
    }
    
    func testTextViewRemoveFilterRestoreDelegate() {
        let delegate = TestTextViewDelegate(callback: { })
        let textView = UITextView(frame: .zero)
        textView.delegate = delegate
        textView.setInputFilter(TestFilter())
        XCTAssertFalse(textView.delegate === delegate)
        textView.setInputFilter(nil)
        XCTAssertTrue(textView.delegate === delegate)
    }
}
