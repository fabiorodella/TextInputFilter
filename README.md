# TextInputFilter: write your own reusable input filters for `UITextField` and `UITextView`

[![License](https://img.shields.io/cocoapods/l/TextInputFilter.svg?style=flat)](https://github.com/fabiorodella/TextInputFilter/blob/master/LICENSE) ![Platform](https://img.shields.io/cocoapods/p/TextInputFilter.svg?style=flat) [![CocoaPods Compatible](https://img.shields.io/cocoapods/v/TextInputFilter.svg)](https://img.shields.io/cocoapods/v/TextInputFilter.svg) [![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

TextInputFilter allows you to write contained and reusable input filters, that can filter and/or transform input as it's typed. The same filters can be used for `UITextField` or `UITextView`.

## Examples

These examples show the usage of a basic input filter with `UITextField`, but you can also use the same filter with `UITextView`.

### Writing an input filter

An input filter can respond to input in three ways:
* `.accept`: input is applied as-is
* `.transform`: a transformed version of the input is set
* `.reject`: input is rejected and text is not changed

The input filter will install a delegate that handles the `shouldChange...` methods, but any other delegate methods are forwarded to the original `delegate` (even if it was set after the input filter).

This example shows a very simple input filter that just converts input to uppercase.

```swift
import TextInputFilter

struct UppercaseInputFilter: TextInputFilter {
    func result(for change: String, appliedTo original: String, replacingRange range: Range<String.Index>, changed: String) -> TextInputFilterResult {
        return .transform(changed.uppercased())
    }
}
```

### Setting the input filter

```swift
import TextInputFilter

struct UppercaseInputFilter: TextInputFilter {
    func result(for change: String, appliedTo original: String, replacingRange range: Range<String.Index>, changed: String) -> TextInputFilterResult {
        return .transform(changed.uppercased())
    }
}
...
let textField = UITextField(frame: frame)
textField.setInputFilter(UppercaseInputFilter(), onChange: { print("Changed: \($0)") })
textField.delegate = self // You can still use delegate methods other than textField(_:shouldChangeCharactersIn:replacementString:)
```

## Requirements

TextInputFilter is compatible with Swift 4.x., and requires iOS 9.0+

## Installation

### Copy files

Just drop the files inside the `Sources` directory anywhere in your own project.

### Framework

Download the repo, drag `TextInputFilter.xcodeproj` into your own project and link the appropriate target for your platform.

### CocoaPods
Inside your `Podfile`:
```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'

target 'TargetName' do
use_frameworks!
pod 'TextInputFilter'
end
```

### Carthage
Inside your `Cartfile`:
```ogdl
github "fabiorodella/TextInputFilter"
```
