//
//  CodeField.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 08.12.2023.
//

import UIKit

final class CodeField: PaddingTextField {
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
extension CodeField: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = Appearance.primary1.cgColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderColor = Appearance.background2.cgColor
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        text = string
        sendActions(for: .editingChanged)
        
        return false
    }
}

// MARK: Private
private extension CodeField {
    func initialize() {
        let attrs = TextAttributes()
            .textColor(Appearance.black2)
            .font(Fonts.RobotoCondensed.medium(size: 28.scale))
            .lineHeight(33.6.scale)
            .textAlignment(.center)
        
        textPadding = UIEdgeInsets(value: 16.scale)
        layer.cornerRadius = 10.scale
        layer.borderWidth = 1.scale
        layer.borderColor = Appearance.background2.cgColor
        backgroundColor = Appearance.white
        delegate = self
        defaultTextAttributes = attrs.dictionary
        borderStyle = .none
    }
}
