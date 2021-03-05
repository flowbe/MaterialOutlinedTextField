//
//  MaterialOutlinedTextField.swift
//  MaterialOutlinedTextField
//
//  Created by Florentin on 28/02/2021.
//  Copyright © 2021 Florentin. All rights reserved.
//

import UIKit

public class MaterialOutlinedTextField: UITextField {

    // MARK: - Enums

    /// Possible behaviors for the label
    public enum LabelBehavior {
        case floats, disappears
    }

    private enum LabelPosition {
        case none, floating, normal

        static func with(hasLabelText: Bool, hasText: Bool, canLabelFloat: Bool, isEditing: Bool) -> LabelPosition {
            if hasLabelText {
                if isEditing || hasText {
                    return canLabelFloat ? .floating : .none
                } else {
                    return .normal
                }
            }
            return .none
        }
    }

    /// Possible states for the text field
    public enum State {
        case normal, editing, disabled

        static func with(isEnabled: Bool, isEditing: Bool) -> State {
            if isEnabled {
                return isEditing ? .editing : .normal
            }
            return .disabled
        }
    }

    // MARK: - Properties

    /// The floating label.
    public var label = UILabel()
    /// Defines the behavior of the label when the text field is editing.  The possible values are `floats` (default) or `disappears`.
    public var labelBehavior = LabelBehavior.floats
    /// The corner radius of the text field.
    public var containerRadius: CGFloat = 4
    /// The current color model based on the current state.
    public var colorModel: ColorModel {
        return colorModels[textControlState] ?? ColorModel(with: textControlState)
    }
    /// The current outline line width based on the current state.
    public var outlineLineWidth: CGFloat {
        return outlineLineWidths[textControlState] ?? 1.0
    }

    private var textControlState: State {
        State.with(isEnabled: isEnabled, isEditing: isEditing)
    }
    private var labelPosition: LabelPosition {
        LabelPosition.with(hasLabelText: !(label.text?.isEmpty ?? true),
            hasText: !(text?.isEmpty ?? true),
            canLabelFloat: labelBehavior == .floats,
            isEditing: isEditing)
    }
    private var colorModels: [State: ColorModel] = [
            .normal: ColorModel(with: .normal),
            .editing: ColorModel(with: .editing),
            .disabled: ColorModel(with: .disabled)
    ]
    private var outlineLineWidths: [State: CGFloat] = [
            .normal: 1.0,
            .editing: 2.0,
            .disabled: 1.0
    ]
    private var shouldPlaceholderBeVisible: Bool {
        let hasPlaceholder = !(placeholder?.isEmpty ?? true)
        let hasText = !(text?.isEmpty ?? true)
        return hasPlaceholder && !hasText && labelPosition != .normal
    }
    private var normalFont: UIFont {
        font ?? UIFont.preferredFont(forTextStyle: .body)
    }
    private var floatingFont: UIFont {
        let font = normalFont
        return font.withSize(font.pointSize * 0.8)
    }

    private var outlineSublayer = CAShapeLayer()
    private var labelFrame = CGRect.zero

    // MARK: - Constants

    private let animationDuration: TimeInterval = 0.15
    private let leftPadding: CGFloat = 16
    private let rightPadding: CGFloat = 12
    private let clearButtonSideLength: CGFloat = 24
    private let floatingLabelOutlineSidePadding: CGFloat = 4

    // MARK: - Object lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        initTextField()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initTextField()
    }

    private func initTextField() {
        setUpLabel()
        setUpOutlineSublayer()
    }

    // MARK: - View setup

    private func setUpLabel() {
        addSubview(label)
    }

    private func setUpOutlineSublayer() {
        outlineSublayer.fillColor = UIColor.clear.cgColor
        outlineSublayer.lineWidth = outlineLineWidth
    }

    // MARK: - Accessors

    /// Set the color model for the specified state.
    /// - Parameters:
    ///   - colorModel: Color model
    ///   - state: State
    public func setColorModel(_ colorModel: ColorModel, for state: State) {
        colorModels[state] = colorModel
        setNeedsLayout()
    }

    /// Set the outline line width for the specified state.
    /// - Parameters:
    ///   - outlineLineWidth: Outline line width
    ///   - state: State
    public func setOutlineLineWidth(_ outlineLineWidth: CGFloat, for state: State) {
        outlineLineWidths[state] = outlineLineWidth
        setNeedsLayout()
    }

    // MARK: - UIView overrides

    public override func layoutSubviews() {
        preLayoutSubviews()
        super.layoutSubviews()
        postLayoutSubviews()
    }

    public override var intrinsicContentSize: CGSize {
        return CGSize(width: bounds.width, height: 56)
    }

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setNeedsLayout()
    }

    // MARK: - Layout

    private func preLayoutSubviews() {
        applyColors()
        switch labelPosition {
        case .none:
            self.labelFrame = .zero
        case .normal:
            self.labelFrame = labelFrameNormal
        case .floating:
            self.labelFrame = labelFrameFloating
        }
    }

    private func postLayoutSubviews() {
        label.isHidden = labelPosition == .none
        animateLabel()
        applyStyle()
    }

    // MARK: - UITextField Layout Overrides

    public override func textRect(forBounds bounds: CGRect) -> CGRect {
        let superRect = super.textRect(forBounds: bounds)
        return CGRect(x: leftPadding, y: superRect.origin.y, width: superRect.width - leftPadding * 1.5, height: superRect.height)
    }

    public override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let superRect = super.editingRect(forBounds: bounds)
        return CGRect(x: leftPadding, y: superRect.origin.y, width: superRect.width - leftPadding * 1.5, height: superRect.height)
    }

    public override func borderRect(forBounds bounds: CGRect) -> CGRect {
        return .zero
    }

    public override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        if shouldPlaceholderBeVisible {
            return super.placeholderRect(forBounds: bounds)
        }
        return .zero
    }

    public override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: frame.width - clearButtonSideLength - rightPadding, y: (frame.height - clearButtonSideLength) / 2, width: clearButtonSideLength, height: clearButtonSideLength)
    }

    // MARK: - UITextField drawing overrides

    public override func drawPlaceholder(in rect: CGRect) {
        if shouldPlaceholderBeVisible {
            super.drawPlaceholder(in: rect)
        }
    }

    // MARK: - Label

    private var labelFrameNormal: CGRect {
        let rect = textRect(forBounds: bounds)
        let labelMinX = rect.minX
        let labelMaxX = rect.maxX
        let maxWidth = labelMaxX - labelMinX
        let size = floatingLabelSize(with: label.text ?? "", maxWidth: maxWidth, font: normalFont)
        let originX = labelMinX
        let originY = rect.midY - (0.5 * size.height)
        return CGRect(x: originX, y: originY, width: size.width, height: size.height)
    }

    private var labelFrameFloating: CGRect {
        let rect = textRect(forBounds: bounds)
        let labelMinX = rect.minX
        let labelMaxX = rect.maxX
        let maxWidth = labelMaxX - labelMinX
        let size = floatingLabelSize(with: label.text ?? "", maxWidth: maxWidth, font: floatingFont)
        let originX = labelMinX
        let originY = 0 - (0.5 * floatingFont.lineHeight)
        return CGRect(x: originX, y: originY, width: size.width, height: size.height)
    }

    private func floatingLabelSize(with placeholder: String, maxWidth: CGFloat, font: UIFont) -> CGSize {
        let fittingSize = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
        var rect = (placeholder as NSString).boundingRect(with: fittingSize, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        rect.size.height = font.lineHeight
        return rect.size
    }

    private func animateLabel() {
        // TODO: Improve animations
        let animations = {
            switch self.labelPosition {
            case .floating:
                self.label.alpha = 1
                self.label.font = self.floatingFont
            case .normal:
                self.label.alpha = 1
                self.label.font = self.normalFont
            case .none:
                self.label.alpha = 0
            }
            self.label.frame = self.labelFrame
        }
        let shouldPerformAnimation = !label.frame.equalTo(.zero)

        if shouldPerformAnimation {
            UIView.animate(withDuration: animationDuration, animations: animations)
        } else {
            animations()
        }
    }

    // MARK: - Coloring and style

    private func applyColors() {
        let labelColor: UIColor
        switch labelPosition {
        case .none:
            labelColor = .clear
        case .normal:
            labelColor = colorModel.normalLabelColor
        case .floating:
            labelColor = colorModel.floatingLabelColor
        }
        label.textColor = labelColor
        textColor = colorModel.textColor
    }

    private func applyStyle() {
        let path = outlinePath(with: bounds, labelFrame: labelFrame, containerHeight: bounds.height, lineWidth: outlineLineWidth, cornerRadius: containerRadius, isLabelFloating: labelPosition == .floating)
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        outlineSublayer.path = path.cgPath
        outlineSublayer.lineWidth = outlineLineWidth
        CATransaction.commit()
        outlineSublayer.fillColor = backgroundColor?.cgColor
        outlineSublayer.strokeColor = colorModel.outlineColor.cgColor

        if outlineSublayer.superlayer != layer {
            layer.insertSublayer(outlineSublayer, at: 0)
        }
    }

    private func outlinePath(with viewBounds: CGRect, labelFrame: CGRect, containerHeight: CGFloat, lineWidth: CGFloat, cornerRadius: CGFloat, isLabelFloating: Bool) -> UIBezierPath {
        let path = UIBezierPath()
        let textFieldWidth = viewBounds.width
        let sublayerMinY = CGFloat.zero
        let sublayerMaxY = containerHeight

        let startingPoint = CGPoint(x: cornerRadius, y: sublayerMinY)
        let topRightCornerPoint1 = CGPoint(x: textFieldWidth - cornerRadius, y: sublayerMinY)
        path.move(to: startingPoint)
        if isLabelFloating {
            let leftLineBreak = labelFrame.minX - floatingLabelOutlineSidePadding
            let rightLineBreak = labelFrame.maxX + floatingLabelOutlineSidePadding
            path.addLine(to: CGPoint(x: leftLineBreak, y: sublayerMinY))
            path.move(to: CGPoint(x: rightLineBreak, y: sublayerMinY))
            path.addLine(to: CGPoint(x: rightLineBreak, y: sublayerMinY))
        } else {
            path.addLine(to: topRightCornerPoint1)
        }

        let topRightCornerPoint2 = CGPoint(x: textFieldWidth, y: sublayerMinY + cornerRadius)
        path.addTopRightCorner(from: topRightCornerPoint1, to: topRightCornerPoint2, with: cornerRadius)

        let bottomRightCornerPoint1 = CGPoint(x: textFieldWidth, y: sublayerMaxY - cornerRadius)
        let bottomRightCornerPoint2 = CGPoint(x: textFieldWidth - cornerRadius, y: sublayerMaxY)
        path.addLine(to: bottomRightCornerPoint1)
        path.addBottomRightCorner(from: bottomRightCornerPoint1, to: bottomRightCornerPoint2, with: cornerRadius)

        let bottomLeftCornerPoint1 = CGPoint(x: cornerRadius, y: sublayerMaxY)
        let bottomLeftCornerPoint2 = CGPoint(x: 0, y: sublayerMaxY - cornerRadius)
        path.addLine(to: bottomLeftCornerPoint1)
        path.addBottomLeftCorner(from: bottomLeftCornerPoint1, to: bottomLeftCornerPoint2, with: cornerRadius)

        let topLeftCornerPoint1 = CGPoint(x: 0, y: sublayerMinY + cornerRadius)
        let topLeftCornerPoint2 = CGPoint(x: cornerRadius, y: sublayerMinY)
        path.addLine(to: topLeftCornerPoint1)
        path.addTopLeftCorner(from: topLeftCornerPoint1, to: topLeftCornerPoint2, with: cornerRadius)

        return path
    }
}
