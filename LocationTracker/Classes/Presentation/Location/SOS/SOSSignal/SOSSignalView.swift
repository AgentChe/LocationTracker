//
//  SOSSignalView.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 17.01.2024.
//

import UIKit
import RxSwift
import RxCocoa

final class SOSSignalView: UIView {
    lazy var closeButton = makeCloseButton()
    lazy var timerLabel = makeLabel()
    lazy var progressView = makeProgressView()
    lazy var enterPINLabel = makeEnterPINLabel()
    lazy var code1Field = makePinField()
    lazy var code2Field = makePinField()
    lazy var code3Field = makePinField()
    lazy var code4Field = makePinField()
    lazy var sendedLabel = makeSendedLabel()
    lazy var placeholderLabel = makePlaceholderLabel()
    lazy var preloader = makePreloader()
    
    private lazy var didInputCodeTrigger = PublishRelay<String>()
    
    lazy var codesFields = [
        code1Field,
        code2Field,
        code3Field,
        code4Field
    ]
    
    private lazy var timerAttrs = TextAttributes()
        .textColor(Appearance.white)
        .font(Fonts.RobotoCondensed.medium(size: 24.scale))
        .lineHeight(33.6.scale)
        .textAlignment(.center)

    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var placeholderBottomConstraint = NSLayoutConstraint()
    
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
extension SOSSignalView {
    func setup(seconds: Int) {
        let minute = Int(seconds) / 60 % 60
        let second = Int(seconds) % 60
        
        let time = String(format: "%02i:%02i", minute, second)
        
        timerLabel.attributedText = time.attributed(with: timerAttrs)
    }
    
    var didInputCode: Signal<String> {
        didInputCodeTrigger.asSignal()
    }
}

// MARK: Private
private extension SOSSignalView {
    func initialize() {
        backgroundColor = Appearance.red
        
        rx.keyboardHeight
            .bind(to: Binder(self) { base, keyboardHeight in
                base.updatePlaceholderPosition(keyboardHeight: keyboardHeight)
            })
            .disposed(by: disposeBag)
    }
    
    func updatePlaceholderPosition(keyboardHeight: CGFloat) {
        placeholderBottomConstraint.constant = -(keyboardHeight + 16.scale)
        
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.layoutIfNeeded()
        })
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
private extension SOSSignalView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            closeButton.widthAnchor.constraint(equalToConstant: 24.scale),
            closeButton.heightAnchor.constraint(equalToConstant: 24.scale),
            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            closeButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            timerLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            timerLabel.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            progressView.leadingAnchor.constraint(equalTo: leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: trailingAnchor),
            progressView.topAnchor.constraint(equalTo: timerLabel.bottomAnchor, constant: 16.scale),
            progressView.heightAnchor.constraint(equalToConstant: 5.scale)
        ])
        
        NSLayoutConstraint.activate([
            enterPINLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40.scale),
            enterPINLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40.scale),
            enterPINLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 60.scale)
        ])
        
        NSLayoutConstraint.activate([
            code1Field.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 80.scale),
            code1Field.topAnchor.constraint(equalTo: enterPINLabel.bottomAnchor, constant: 16.scale)
        ])
        
        NSLayoutConstraint.activate([
            code2Field.leadingAnchor.constraint(equalTo: code1Field.trailingAnchor, constant: 8.scale),
            code2Field.topAnchor.constraint(equalTo: enterPINLabel.bottomAnchor, constant: 16.scale)
        ])
        
        NSLayoutConstraint.activate([
            code3Field.leadingAnchor.constraint(equalTo: code2Field.trailingAnchor, constant: 8.scale),
            code3Field.topAnchor.constraint(equalTo: enterPINLabel.bottomAnchor, constant: 16.scale)
        ])
        
        NSLayoutConstraint.activate([
            code4Field.leadingAnchor.constraint(equalTo: code3Field.trailingAnchor, constant: 8.scale),
            code4Field.topAnchor.constraint(equalTo: enterPINLabel.bottomAnchor, constant: 16.scale)
        ])
        
        NSLayoutConstraint.activate([
            sendedLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            sendedLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            sendedLabel.topAnchor.constraint(equalTo: code1Field.bottomAnchor, constant: 32.scale)
        ])
        
        NSLayoutConstraint.activate([
            preloader.widthAnchor.constraint(equalToConstant: 45.scale),
            preloader.heightAnchor.constraint(equalToConstant: 45.scale),
            preloader.centerXAnchor.constraint(equalTo: centerXAnchor),
            preloader.topAnchor.constraint(equalTo: sendedLabel.bottomAnchor, constant: 16.scale)
        ])
        
        placeholderBottomConstraint = placeholderLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16.scale)
        NSLayoutConstraint.activate([
            placeholderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32.scale),
            placeholderLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32.scale),
            placeholderBottomConstraint
        ])
    }
}

// MARK: Lazy initialization
private extension SOSSignalView {
    func makeCloseButton() -> TapAreaButton {
        let view = TapAreaButton()
        view.setImage(UIImage(named: "SOSSignal.Close"), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeProgressView() -> UIProgressView {
        let view = UIProgressView()
        view.trackTintColor = Appearance.white.withAlphaComponent(0.1)
        view.progressTintColor = Appearance.white
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeEnterPINLabel() -> PaddingLabel {
        let attrs = TextAttributes()
            .textColor(Appearance.white)
            .font(Fonts.RobotoCondensed.regular(size: 18.scale))
            .lineHeight(25.2.scale)
            .textAlignment(.center)
        
        let view = PaddingLabel()
        view.attributedText = "SOSSignal.EnterPIN".localized.attributed(with: attrs)
        view.insets = UIEdgeInsets(vertical: 8.scale)
        view.backgroundColor = Appearance.white.withAlphaComponent(0.2)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makePinField() -> SOSSignalPINField {
        let view = SOSSignalPINField()
        view.addTarget(self, action: #selector(didInputCode(inField:)), for: .editingChanged)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeSendedLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.white)
            .font(Fonts.RobotoCondensed.medium(size: 24.scale))
            .lineHeight(33.6.scale)
            .textAlignment(.center)
        
        let view = UILabel()
        view.isHidden = true
        view.numberOfLines = 0
        view.attributedText = "SOSSignal.SignalSended".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makePlaceholderLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.white)
            .font(Fonts.RobotoCondensed.regular(size: 16.scale))
            .lineHeight(22.4.scale)
            .textAlignment(.center)
        
        let view = UILabel()
        view.numberOfLines = 0
        view.attributedText = "SOSSignal.Placeholder".localized.attributed(with: attrs)
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
