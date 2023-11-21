//
//  EnablePermissionView.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 21.11.2023.
//

import UIKit

final class EnablePermissionView: UIView {
    enum Result {
        case enable, skip
    }
    
    lazy var dimmedView = makeDimmedView()
    lazy var container = makeContainer()
    lazy var titleLabel = makeTitleLabel()
    lazy var subTitleLabel = makeSubTitleLabel()
    lazy var enableButton = makeEnableButton()
    lazy var skipButton = makeSkipButton()
    
    private var completion: ((Result?) -> Void)?
    private var result: Result?
    
    private lazy var containerYConstraint = NSLayoutConstraint()
    
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
extension EnablePermissionView {
    func show(completion: ((Result?) -> Void)?) {
        self.completion = completion
        self.result = nil
        
        isHidden = false
        
        containerYConstraint.isActive = false
        containerYConstraint = container.bottomAnchor.constraint(equalTo: bottomAnchor)
        containerYConstraint.isActive = true
        
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.dimmedView.alpha = 0.2
            self?.layoutIfNeeded()
        })
    }
    
    func hide() {
        containerYConstraint.isActive = false
        containerYConstraint = container.topAnchor.constraint(equalTo: bottomAnchor)
        containerYConstraint.isActive = true
        
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.dimmedView.alpha = 0
            self?.layoutIfNeeded()
        }, completion: { [weak self] result in
            self?.isHidden = true
            
            self?.completion?(self?.result)
            
            self?.completion = nil
            self?.result = nil
        })
    }
}

// MARK: Private
private extension EnablePermissionView {
    func initialize() {
        backgroundColor = UIColor.clear
        dimmedView.alpha = 0
        isHidden = true
    }
    
    @objc
    func enableTapped() {
        result = .enable
        
        hide()
    }
    
    @objc
    func skipTapped() {
        result = .skip
        
        hide()
    }
}

// MARK: Make constraints
private extension EnablePermissionView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            dimmedView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dimmedView.trailingAnchor.constraint(equalTo: trailingAnchor),
            dimmedView.topAnchor.constraint(equalTo: topAnchor),
            dimmedView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        containerYConstraint = container.topAnchor.constraint(equalTo: bottomAnchor)
        NSLayoutConstraint.activate([
            containerYConstraint,
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 24.scale)
        ])
        
        NSLayoutConstraint.activate([
            subTitleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            subTitleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4.scale)
        ])
        
        NSLayoutConstraint.activate([
            enableButton.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            enableButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            enableButton.heightAnchor.constraint(equalToConstant: 56.scale),
            enableButton.topAnchor.constraint(equalTo: subTitleLabel.bottomAnchor, constant: 27.scale)
        ])
        
        NSLayoutConstraint.activate([
            skipButton.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            skipButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            skipButton.heightAnchor.constraint(equalToConstant: 56.scale),
            skipButton.topAnchor.constraint(equalTo: enableButton.bottomAnchor, constant: 12.scale),
            skipButton.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: ScreenSize.isIphoneXFamily ? -60.scale : -30.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension EnablePermissionView {
    func makeDimmedView() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.black2
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.background1
        view.layer.cornerRadius = 20.scale
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.black2)
            .font(Fonts.RobotoCondensed.medium(size: 18.scale))
            .lineHeight(25.2.scale)
            .textAlignment(.center)
        
        let view = UILabel()
        view.attributedText = "Onboarding.EnablePermission.Title".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeSubTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.black1)
            .font(Fonts.RobotoCondensed.regular(size: 16.scale))
            .lineHeight(22.4.scale)
            .textAlignment(.center)
        
        let view = UILabel()
        view.attributedText = "Onboarding.EnablePermission.SubTitle".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeEnableButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.white)
            .font(Fonts.RobotoCondensed.medium(size: 16.scale))
        
        let view = UIButton()
        view.setAttributedTitle("Onboarding.EnablePermission.EnableButton".localized.attributed(with: attrs), for: .normal)
        view.backgroundColor = Appearance.primary1
        view.layer.cornerRadius = 20.scale
        view.addTarget(self, action: #selector(enableTapped), for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeSkipButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.primary1)
            .font(Fonts.RobotoCondensed.medium(size: 16.scale))
        
        let view = UIButton()
        view.setAttributedTitle("Onboarding.EnablePermission.SkipButton".localized.attributed(with: attrs), for: .normal)
        view.backgroundColor = Appearance.primary2
        view.layer.cornerRadius = 20.scale
        view.addTarget(self, action: #selector(skipTapped), for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
}
