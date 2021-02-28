//
//  ColorModel.swift
//  MaterialOutlinedTextField
//
//  Created by Florentin on 28/02/2021.
//  Copyright © 2021 Florentin. All rights reserved.
//

import UIKit

public struct ColorModel {
    /// Text color.
    public var textColor: UIColor
    /// Floating label color.
    public var floatingLabelColor: UIColor
    /// Normal label color.
    public var normalLabelColor: UIColor
    /// Outline line color.
    public var outlineColor: UIColor

    public init(with state: MaterialOutlinedTextField.State) {
        var textColor = UIColor.black
        var floatingLabelColor = UIColor.black
        var normalLabelColor = UIColor.darkGray
        var outlineColor = UIColor.black

        if #available(iOS 13.0, *) {
            textColor = .label
            floatingLabelColor = .label
            normalLabelColor = .label
            outlineColor = .label
        }

        let disabledAlpha: CGFloat = 0.6

        if state == .disabled {
            textColor = textColor.withAlphaComponent(disabledAlpha)
            floatingLabelColor = floatingLabelColor.withAlphaComponent(disabledAlpha)
            normalLabelColor = normalLabelColor.withAlphaComponent(disabledAlpha)
            outlineColor = normalLabelColor.withAlphaComponent(disabledAlpha)
        }

        self.init(textColor: textColor,
            floatingLabelColor: floatingLabelColor,
            normalLabelColor: normalLabelColor,
            outlineColor: outlineColor)
    }

    /// Creates a new color model.
    /// - Parameters:
    ///   - textColor: Text color
    ///   - floatingLabelColor: Floating label color
    ///   - normalLabelColor: Normal label color
    ///   - outlineColor: Outline line color
    public init(textColor: UIColor, floatingLabelColor: UIColor, normalLabelColor: UIColor, outlineColor: UIColor) {
        self.textColor = textColor
        self.floatingLabelColor = floatingLabelColor
        self.normalLabelColor = normalLabelColor
        self.outlineColor = outlineColor
    }
}
