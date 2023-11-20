//
//  OPinView.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 20.11.2023.
//

import UIKit

protocol OPINViewDelegate: AnyObject {
    func pinViewDidSet(pin: String)
}

final class OPINView: OSlideView {
    weak var mainDelegate: OPINViewDelegate?
    
    lazy var titleLabel = makeTitleLabel()
    lazy var code1Field = makePinField()
    lazy var code2Field = makePinField()
    lazy var code3Field = makePinField()
    lazy var code4Field = makePinField()
    lazy var subTitleLabel = makeSubTitleLabel()
    lazy var continueButton = makeContinueButton()
    
    private lazy var codesFields = [
        code1Field,
        code2Field,
        code3Field,
        code4Field
    ]
    
    override init(step: OnboardingView.Step) {
        super.init(step: step)
        
        makeConstraints()
        initialize()
        changeEnable()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func moveToThis() {
        super.moveToThis()
        
        code1Field.becomeFirstResponder()
    }
}

// MARK: Private
private extension OPINView {
    func initialize() {
        backgroundColor = Appearance.background1
    }
    
    @objc
    func continueTapped() {
        let pin = codesFields
            .map { $0.text ?? "" }
            .joined()
        
        mainDelegate?.pinViewDidSet(pin: pin)
        
        onNext()
    }
    
    @objc
    func didInputCode(inField: UITextField) {
        changeEnable()
        
        if let nextField = nextField(from: inField) {
            nextField.becomeFirstResponder()
            return
        }
        
        inField.resignFirstResponder()
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
    
    func changeEnable() {
        let enable = !codesFields.contains(where: { ($0.text ?? "").isEmpty })
        continueButton.isEnabled = enable
        continueButton.alpha = enable ? 1 : 0.4
    }
}

// MARK: Make constraints
private extension OPINView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: ScreenSize.isIphoneXFamily ? 120.scale : 60.scale)
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
        
        NSLayoutConstraint.activate([
            subTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            subTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            subTitleLabel.topAnchor.constraint(equalTo: code1Field.bottomAnchor, constant: 24.scale)
        ])
        
        NSLayoutConstraint.activate([
            continueButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            continueButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            continueButton.heightAnchor.constraint(equalToConstant: 56.scale),
            continueButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: ScreenSize.isIphoneXFamily ? -60.scale : -30.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension OPINView {
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.black2)
            .font(Fonts.RobotoCondensed.medium(size: 24.scale))
            .lineHeight(33.6.scale)
            .textAlignment(.center)
        
        let view = UILabel()
        view.attributedText = "Onboarding.PIN.Title".localized.attributed(with: attrs)
        view.numberOfLines = 0
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
    
    func makeSubTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.black1)
            .font(Fonts.RobotoCondensed.regular(size: 16.scale))
            .lineHeight(22.4.scale)
            .textAlignment(.center)
        
        let view = UILabel()
        view.attributedText = "Onboarding.PIN.SubTitle".localized.attributed(with: attrs)
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeContinueButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.white)
            .font(Fonts.RobotoCondensed.medium(size: 16.scale))
        
        let view = UIButton()
        view.setAttributedTitle("Onboarding.PIN.ContinueButton".localized.attributed(with: attrs), for: .normal)
        view.backgroundColor = Appearance.primary1
        view.layer.cornerRadius = 20.scale
        view.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
