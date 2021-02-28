# MaterialOutlinedTextField

A simple [Material Design outlined text field](https://material.io/components/text-fields) implementation in Swift.

## Installation

Installation can be done using Swift Package Manager. In Xcode, go to File > Swift Packages > Add Package Dependency… and paste the repository URL (https://github.com/flowbe/MaterialOutlinedTextField) to add it.

You can also add the dependency directly in your `Package.swift` file:
```swift
dependencies: [
    .package(url: "https://github.com/flowbe/MaterialOutlinedTextField.git", .upToNextMajor(from: "0.1.0"))
]
```

## Usage

`MaterialOutlinedTextField` has the same interface as `UITextField` with a few extra properties and methods:

- `label`: The label appearing as floating or placeholder. You can use this property to set his text content.
- `labelBehavior`: Defines the behavior of the label when the text field is editing. The possible values are `floats` (default) or `disappears`. 
- `containerRadius`: The corner radius of the text field.
- `colorModel`: The current color model based on the current state (get-only).
- `outlineLineWidth`: The current outline line width model based on the current state (get-only).
- `setColorModel(_ colorModel: ColorModel, for state: State)`: Set the color model for the specified state.
- `setOutlineLineWidth(_ outlineLineWidth: CGFloat, for state: State)`: Set the color model for the specified state.

## Example

```swift
let t = MaterialOutlinedTextField(frame: CGRect(x: 0, y: 0, width: 200, height: 56))
textField.label.text = "Label"
textField.placeholder = "Placeholder"
textField.clearButtonMode = .whileEditing
textField.setColorModel(ColorModel(textColor: .gray, floatingLabelColor: .gray, normalLabelColor: .gray, outlineColor: .gray), for: .normal)
textField.setColorModel(ColorModel(textColor: .systemBlue, floatingLabelColor: .systemBlue, normalLabelColor: .systemBlue, outlineColor: .systemBlue), for: .editing)
textField.setColorModel(ColorModel(with: .disabled), for: .disabled)
```
