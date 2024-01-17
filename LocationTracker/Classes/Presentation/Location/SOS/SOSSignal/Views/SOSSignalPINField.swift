//
//  SOSSignalPINField.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 17.01.2024.
//

import UIKit

final class SOSSignalPINField: PaddingTextField {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: 48.scale, height: 56.scale)
    }
}

// MARK: UITextFieldDelegate
extension SOSSignalPINField: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = Appearance.white.cgColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.clear.cgColor
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if Int(string) != nil {
            text = string
            sendActions(for: .editingChanged)
        }
        
        return false
    }
}

// MARK: Private
private extension SOSSignalPINField {
    func initialize() {
        let attrs = TextAttributes()
            .textColor(Appearance.white)
            .font(Fonts.RobotoCondensed.medium(size: 28.scale))
            .lineHeight(33.6.scale)
            .textAlignment(.center)
        
        textPadding = UIEdgeInsets(value: 16.scale)
        layer.cornerRadius = 10.scale
        layer.borderWidth = 1.scale
        layer.borderColor = UIColor.clear.cgColor
        backgroundColor = Appearance.white.withAlphaComponent(0.4)
        delegate = self
        keyboardType = .decimalPad
        defaultTextAttributes = attrs.dictionary
        borderStyle = .none
    }
}
