//
//  JoinToCircleView.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 08.12.2023.
//

import UIKit
import RxSwift

final class JoinToCircleView: UIView {
    lazy var code1Field = makeCodeField()
    lazy var code2Field = makeCodeField()
    lazy var code3Field = makeCodeField()
    lazy var code4Field = makeCodeField()
    lazy var code5Field = makeCodeField()
    lazy var code6Field = makeCodeField()
    lazy var descriptionLabel = makeDescriptionLabel()
    lazy var submitButton = makeSubmitButton()
    lazy var preloader = makePreloader()
    
    lazy var codesFields = [
        code1Field,
        code2Field,
        code3Field,
        code4Field,
        code5Field,
        code6Field
    ]
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var submitButtonBottomConstraint = NSLayoutConstraint()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
        initialize()
        changeEnable()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension JoinToCircleView {
    func initialize() {
        backgroundColor = Appearance.background1
        
        rx.keyboardHeight
            .bind(to: Binder(self) { base, keyboardHeight in
                base.updateSubmitButtonPosition(keyboardHeight: keyboardHeight)
            })
            .disposed(by: disposeBag)
    }
    
    func updateSubmitButtonPosition(keyboardHeight: CGFloat) {
        let constant = keyboardHeight > 0 ? -(keyboardHeight + 12.scale) : (ScreenSize.isIphoneXFamily ? -60.scale : -30.scale)
        
        submitButtonBottomConstraint.isActive = false
        submitButtonBottomConstraint.constant = constant
        submitButtonBottomConstraint.isActive = true
        
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.layoutIfNeeded()
        })
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
        submitButton.isEnabled = enable
        submitButton.alpha = enable ? 1 : 0.4
    }
}

// MARK: Make constraints
private extension JoinToCircleView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            code1Field.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24.scale),
            code1Field.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 47.scale)
        ])
        
        NSLayoutConstraint.activate([
            code2Field.leadingAnchor.constraint(equalTo: code1Field.trailingAnchor, constant: 8.scale),
            code2Field.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 47.scale)
        ])
        
        NSLayoutConstraint.activate([
            code3Field.leadingAnchor.constraint(equalTo: code2Field.trailingAnchor, constant: 8.scale),
            code3Field.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 47.scale)
        ])
        
        NSLayoutConstraint.activate([
            code4Field.leadingAnchor.constraint(equalTo: code3Field.trailingAnchor, constant: 8.scale),
            code4Field.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 47.scale)
        ])
        
        NSLayoutConstraint.activate([
            code5Field.leadingAnchor.constraint(equalTo: code4Field.trailingAnchor, constant: 8.scale),
            code5Field.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 47.scale)
        ])
        
        NSLayoutConstraint.activate([
            code6Field.leadingAnchor.constraint(equalTo: code5Field.trailingAnchor, constant: 8.scale),
            code6Field.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 47.scale)
        ])
        
        NSLayoutConstraint.activate([
            descriptionLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: code1Field.bottomAnchor, constant: 24.scale)
        ])
        
        submitButtonBottomConstraint = submitButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: ScreenSize.isIphoneXFamily ? -60.scale : -30.scale)
        NSLayoutConstraint.activate([
            submitButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            submitButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            submitButton.heightAnchor.constraint(equalToConstant: 56.scale),
            submitButtonBottomConstraint
        ])
        
        NSLayoutConstraint.activate([
            preloader.centerXAnchor.constraint(equalTo: centerXAnchor),
            preloader.centerYAnchor.constraint(equalTo: centerYAnchor),
            preloader.widthAnchor.constraint(equalToConstant: 45.scale),
            preloader.heightAnchor.constraint(equalToConstant: 45.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension JoinToCircleView {
    func makeCodeField() -> CodeField {
        let view = CodeField()
        view.addTarget(self, action: #selector(didInputCode(inField:)), for: .editingChanged)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeDescriptionLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.black1)
            .font(Fonts.RobotoCondensed.regular(size: 16.scale))
            .lineHeight(22.4.scale)
            .textAlignment(.center)
        
        let view = UILabel()
        view.attributedText = "JoinToCircle.Description".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeSubmitButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.white)
            .font(Fonts.RobotoCondensed.medium(size: 16.scale))
        
        let view = UIButton()
        view.backgroundColor = Appearance.primary1
        view.layer.cornerRadius = 20.scale
        view.setAttributedTitle("JoinToCircle.SubmitButton".localized.attributed(with: attrs), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makePreloader() -> UIActivityIndicatorView {
        let view = UIActivityIndicatorView()
        view.hidesWhenStopped = true
        view.style = .large
        view.color = Appearance.primary1
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
