//
//  OIntroView.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 20.11.2023.
//

import UIKit

final class OIntroView: OSlideView {
    enum Intro {
        case one, two
    }
    
    lazy var imageView = makeImageView()
    lazy var titleLabel = makeTitleLabel()
    lazy var subTitleLabel = makeSubTitleLabel()
    lazy var dot1View = makeDotView(selected: number == 1)
    lazy var dot2View = makeDotView(selected: number == 2)
    lazy var continueButton = makeContinueButton()
    
    private let key: String
    private let number: Int
    private let buttonTitle: String
    
    init(step: OnboardingView.Step, intro: Intro) {
        let data = intro.data
        key = data.0
        number = data.1
        buttonTitle = data.2
        
        super.init(step: step)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension OIntroView {
    func initialize() {
        backgroundColor = Appearance.background1
    }
}

// MARK: Make constraints
private extension OIntroView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 238.scale),
            imageView.heightAnchor.constraint(equalToConstant: 255.scale),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 50.scale)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32.scale),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32.scale),
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 40.scale)
        ])
        
        NSLayoutConstraint.activate([
            subTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            subTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4.scale)
        ])
        
        NSLayoutConstraint.activate([
            dot1View.widthAnchor.constraint(equalToConstant: 8.scale),
            dot1View.heightAnchor.constraint(equalToConstant: 8.scale),
            dot1View.trailingAnchor.constraint(equalTo: centerXAnchor, constant: -4.scale),
            dot1View.bottomAnchor.constraint(equalTo: continueButton.topAnchor, constant: -44.scale)
        ])
        
        NSLayoutConstraint.activate([
            dot2View.widthAnchor.constraint(equalToConstant: 8.scale),
            dot2View.heightAnchor.constraint(equalToConstant: 8.scale),
            dot2View.leadingAnchor.constraint(equalTo: centerXAnchor, constant: 4.scale),
            dot2View.bottomAnchor.constraint(equalTo: continueButton.topAnchor, constant: -44.scale)
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
private extension OIntroView {
    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: key)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.black2)
            .font(Fonts.RobotoCondensed.medium(size: 24.scale))
            .lineHeight(33.6.scale)
            .textAlignment(.center)
        
        let view = UILabel()
        view.attributedText = "\(key).Title".localized.attributed(with: attrs)
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
            .textAlignment(.center)
        
        let view = UILabel()
        view.attributedText = "\(key).SubTitle".localized.attributed(with: attrs)
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeDotView(selected: Bool) -> CircleView {
        let view = CircleView()
        view.backgroundColor = Appearance.secondary.withAlphaComponent(selected ? 1 : 0.4)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeContinueButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.white)
            .font(Fonts.RobotoCondensed.medium(size: 16.scale))
        
        let view = UIButton()
        view.setAttributedTitle(buttonTitle.attributed(with: attrs), for: .normal)
        view.backgroundColor = Appearance.primary1
        view.layer.cornerRadius = 20.scale
        view.addTarget(self, action: #selector(onNext), for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}

// MARK: Additional
private extension OIntroView.Intro {
    var data: (String, Int, String) {
        switch self {
        case .one:
            return ("Onboarding.Intro1", 1, "Continue".localized)
        case .two:
            return ("Onboarding.Intro2", 2, "Onboarding.Intro2.ContinueButton".localized)
        }
    }
}
