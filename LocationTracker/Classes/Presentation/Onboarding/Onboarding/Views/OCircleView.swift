//
//  OCircleView.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 13.12.2023.
//

import UIKit

final class OCircleView: OSlideView {
    var onSkip: (() -> Void)?
    var createCircle: (() -> Void)?
    var joinToCircle: (() -> Void)?
    
    lazy var skipButton = makeSkipButton()
    lazy var imageView = makeImageView()
    lazy var titleLabel = makeTitleLabel()
    lazy var subTitleLabel = makeSubTitleLabel()
    lazy var createCircleButton = makeCreateCircleButton()
    lazy var joinToCircleButton = makeJoinToCircleButton()
    
    private lazy var titleAttrs = TextAttributes()
        .textColor(Appearance.black2)
        .font(Fonts.RobotoCondensed.medium(size: 32.scale))
        .lineHeight(44.8.scale)
        .textAlignment(.left)
    private lazy var nameAttrs = TextAttributes()
        .textColor(Appearance.secondary)
        .font(Fonts.RobotoCondensed.medium(size: 32.scale))
        .lineHeight(44.8.scale)
        .textAlignment(.left)
    
    override init(step: OnboardingView.Step) {
        super.init(step: step)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: ONameViewDelegate
extension OCircleView: ONameViewDelegate {
    func nameViewDidEnter(name: String) {
        let result = NSMutableAttributedString()
        result.append("Onboarding.Circle.Title".localized.attributed(with: titleAttrs))
        result.append(name.attributed(with: nameAttrs))
        titleLabel.attributedText = result
    }
}

// MARK: Private
private extension OCircleView {
    func initialize() {
        backgroundColor = Appearance.background1
    }
    
    @objc
    func skipTapped() {
        onSkip?()
    }
    
    @objc
    func createTapped() {
        createCircle?()
    }
    
    @objc
    func joinTapped() {
        joinToCircle?()
    }
}

// MARK: Make constraints
private extension OCircleView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            skipButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            skipButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 8.scale)
        ])
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: ScreenSize.isIphoneXFamily ? 256.scale : 182.scale),
            imageView.heightAnchor.constraint(equalToConstant: ScreenSize.isIphoneXFamily ? 233.scale : 166.scale),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            imageView.topAnchor.constraint(equalTo: skipButton.bottomAnchor, constant: ScreenSize.isIphoneXFamily ? 73.scale : 30.scale)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 40.scale)
        ])
        
        NSLayoutConstraint.activate([
            subTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            subTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12.scale)
        ])
        
        NSLayoutConstraint.activate([
            createCircleButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            createCircleButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            createCircleButton.heightAnchor.constraint(equalToConstant: 56.scale),
            createCircleButton.bottomAnchor.constraint(equalTo: joinToCircleButton.topAnchor, constant: -16.scale)
        ])
        
        NSLayoutConstraint.activate([
            joinToCircleButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            joinToCircleButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            joinToCircleButton.heightAnchor.constraint(equalToConstant: 56.scale),
            joinToCircleButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: ScreenSize.isIphoneXFamily ? -60.scale : -30.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension OCircleView {
    func makeSkipButton() -> TapAreaButton {
        let attrs = TextAttributes()
            .textColor(Appearance.primary1)
            .font(Fonts.RobotoCondensed.medium(size: 18.scale))
        
        let view = TapAreaButton()
        view.setAttributedTitle("Onboarding.Circle.Skip".localized.attributed(with: attrs), for: .normal)
        view.addTarget(self, action: #selector(skipTapped), for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        view.image = UIImage(named: "Onboarding.Circle")
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTitleLabel() -> UILabel {
        let view = UILabel()
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeSubTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.black1)
            .font(Fonts.RobotoCondensed.regular(size: 16.scale))
            .lineHeight(22.4.scale)
            .textAlignment(.left)
        
        let view = UILabel()
        view.attributedText = "Onboarding.Circle.SubTitle".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeCreateCircleButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.white)
            .font(Fonts.RobotoCondensed.medium(size: 16.scale))
        
        let view = UIButton()
        view.setAttributedTitle("Onboarding.Circle.CreateCircle".localized.attributed(with: attrs), for: .normal)
        view.backgroundColor = Appearance.primary1
        view.layer.cornerRadius = 20.scale
        view.addTarget(self, action: #selector(createTapped), for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeJoinToCircleButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.primary1)
            .font(Fonts.RobotoCondensed.medium(size: 16.scale))
        
        let view = UIButton()
        view.setAttributedTitle("Onboarding.Circle.JoinToCircle".localized.attributed(with: attrs), for: .normal)
        view.backgroundColor = Appearance.primary2
        view.layer.cornerRadius = 20.scale
        view.addTarget(self, action: #selector(joinTapped), for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
