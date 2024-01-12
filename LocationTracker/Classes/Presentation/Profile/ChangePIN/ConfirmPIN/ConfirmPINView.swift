//
//  ConfirmPINView.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 12.01.2024.
//

import UIKit
import RxSwift
import RxCocoa

final class ConfirmPINView: UIView {
    lazy var titleLabel = makeTitleLabel()
    lazy var code1Field = makePinField()
    lazy var code2Field = makePinField()
    lazy var code3Field = makePinField()
    lazy var code4Field = makePinField()
    
    lazy var codesFields = [
        code1Field,
        code2Field,
        code3Field,
        code4Field
    ]
    
    private lazy var didInputCodeTrigger = PublishRelay<String>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension ConfirmPINView {
    var didInputCode: Signal<String> {
        didInputCodeTrigger.asSignal()
    }
}

// MARK: Private
private extension ConfirmPINView {
    func initialize() {
        backgroundColor = Appearance.background1
    }
    
    @objc
    func didInputCode(inField: UITextField) {
        if let nextField = nextField(from: inField) {
            nextField.becomeFirstResponder()
            return
        }
        
        inField.resignFirstResponder()
        
        let pin = codesFields
            .map { $0.text ?? "" }
            .joined()
        
        didInputCodeTrigger.accept(pin)
    }
    
    func nextField(from: UITextField) -> UITextField? {
        guard let index = codesFields.firstIndex(where: { $0 === from }) else {
            return nil
        }
        
        let nextIndex = index + 1
        
        guard codesFields.indices.contains(nextIndex) else {
            return nil
        }
        
        return codesFields[nextIndex]
    }
}

// MARK: Make constraints
private extension ConfirmPINView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 21.scale)
        ])
        
        NSLayoutConstraint.activate([
            code1Field.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 80.scale),
            code1Field.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32.scale)
        ])
        
        NSLayoutConstraint.activate([
            code2Field.leadingAnchor.constraint(equalTo: code1Field.trailingAnchor, constant: 8.scale),
            code2Field.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32.scale)
        ])
        
        NSLayoutConstraint.activate([
            code3Field.leadingAnchor.constraint(equalTo: code2Field.trailingAnchor, constant: 8.scale),
            code3Field.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32.scale)
        ])
        
        NSLayoutConstraint.activate([
            code4Field.leadingAnchor.constraint(equalTo: code3Field.trailingAnchor, constant: 8.scale),
            code4Field.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension ConfirmPINView {
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.black2)
            .font(Fonts.RobotoCondensed.medium(size: 24.scale))
            .lineHeight(33.6.scale)
            .textAlignment(.center)
        
        let view = UILabel()
        view.attributedText = "ConfirmPIN.Title".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makePinField() -> PINField {
        let view = PINField()
        view.addTarget(self, action: #selector(didInputCode(inField:)), for: .editingChanged)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
