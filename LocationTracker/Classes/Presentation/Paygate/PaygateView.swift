//
//  PaygateView.swift
//  CodeChallenge
//
//  Created by Андрей Чернышев on 20.02.2024.
//

import UIKit

final class PaygateView: UIView {
    lazy var imageView = makeImageView()
    lazy var closeButton = makeCloseButton()
    lazy var titleLabel = makeTitleLabel()
    lazy var cell1 = makeCell(number: 1)
    lazy var cell2 = makeCell(number: 2)
    lazy var cell3 = makeCell(number: 3)
    lazy var product1Button = makeProductButton()
    lazy var product2Button = makeProductButton()
    lazy var bestOfferView = makeBestOfferView()
    lazy var enableTrialButton = makeEnableTrialButton()
    lazy var buyButton = makeBuyButton()
    lazy var infoView = makeInfoView()
    lazy var termsOfUseButton = makeActionButton(text: "Paygate.TermsOfUse".localized)
    lazy var privacyPolicyButton = makeActionButton(text: "Paygate.PrivacyPolicy".localized)
    lazy var restoreButton = makeActionButton(text: "Paygate.RestorePurchases".localized)
    lazy var preloader = makePreloader()
    
    private lazy var buyAttrs = TextAttributes()
        .textColor(Appearance.white)
        .font(Fonts.RobotoCondensed.medium(size: 16.scale))
    
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
extension PaygateView {
    func setup(buyTitle: String) {
        buyButton.setAttributedTitle(buyTitle.attributed(with: buyAttrs), for: .normal)
    }
}

// MARK: Private
private extension PaygateView {
    func initialize() {
        backgroundColor = Appearance.background1
    }
}

// MARK: Make constraints
private extension PaygateView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: ScreenSize.isIphoneXFamily ? 247.scale : 158.scale),
            imageView.topAnchor.constraint(equalTo: topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            closeButton.widthAnchor.constraint(equalToConstant: 24.scale),
            closeButton.heightAnchor.constraint(equalToConstant: 24.scale),
            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            closeButton.topAnchor.constraint(equalTo: topAnchor, constant: ScreenSize.isIphoneXFamily ? 68.scale : 30.scale)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: ScreenSize.isIphoneXFamily ? 8.scale : 0)
        ])
        
        NSLayoutConstraint.activate([
            cell1.leadingAnchor.constraint(equalTo: leadingAnchor),
            cell1.trailingAnchor.constraint(equalTo: trailingAnchor),
            cell1.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: ScreenSize.isIphoneXFamily ? 8.scale : 12.scale)
        ])
        
        NSLayoutConstraint.activate([
            cell2.leadingAnchor.constraint(equalTo: leadingAnchor),
            cell2.trailingAnchor.constraint(equalTo: trailingAnchor),
            cell2.topAnchor.constraint(equalTo: cell1.bottomAnchor, constant: ScreenSize.isIphoneXFamily ? 8.scale : 8.scale)
        ])
        
        NSLayoutConstraint.activate([
            cell3.leadingAnchor.constraint(equalTo: leadingAnchor),
            cell3.trailingAnchor.constraint(equalTo: trailingAnchor),
            cell3.topAnchor.constraint(equalTo: cell2.bottomAnchor, constant: ScreenSize.isIphoneXFamily ? 8.scale : 8.scale)
        ])
        
        NSLayoutConstraint.activate([
            enableTrialButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            enableTrialButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            enableTrialButton.topAnchor.constraint(equalTo: cell3.bottomAnchor, constant: ScreenSize.isIphoneXFamily ? 16.scale : 8.scale),
            enableTrialButton.heightAnchor.constraint(equalToConstant: ScreenSize.isIphoneXFamily ? 66.scale : 60.scale)
        ])
        
        NSLayoutConstraint.activate([
            product1Button.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            product1Button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            product1Button.topAnchor.constraint(equalTo: enableTrialButton.bottomAnchor, constant: 16.scale),
            product1Button.heightAnchor.constraint(equalToConstant: ScreenSize.isIphoneXFamily ? 68.scale : 60.scale)
        ])
        
        NSLayoutConstraint.activate([
            product2Button.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            product2Button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            product2Button.topAnchor.constraint(equalTo: product1Button.bottomAnchor, constant: 16.scale),
            product2Button.heightAnchor.constraint(equalToConstant: ScreenSize.isIphoneXFamily ? 68.scale : 60.scale)
        ])
        
        NSLayoutConstraint.activate([
            bestOfferView.centerYAnchor.constraint(equalTo: product1Button.topAnchor),
            bestOfferView.trailingAnchor.constraint(equalTo: product1Button.trailingAnchor, constant: -9.scale)
        ])
        
        NSLayoutConstraint.activate([
            buyButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            buyButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            buyButton.topAnchor.constraint(equalTo: product2Button.bottomAnchor, constant: ScreenSize.isIphoneXFamily ? 14.scale : 16.scale),
            buyButton.heightAnchor.constraint(equalToConstant: 53.scale)
        ])
        
        NSLayoutConstraint.activate([
            infoView.centerXAnchor.constraint(equalTo: centerXAnchor),
            infoView.topAnchor.constraint(equalTo: buyButton.bottomAnchor, constant: 15.scale)
        ])
        
        NSLayoutConstraint.activate([
            termsOfUseButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 38.5.scale),
            termsOfUseButton.centerYAnchor.constraint(equalTo: privacyPolicyButton.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            privacyPolicyButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 131.5.scale),
            privacyPolicyButton.topAnchor.constraint(equalTo: infoView.bottomAnchor, constant: ScreenSize.isIphoneXFamily ? 17.scale : 15.scale)
        ])
        
        NSLayoutConstraint.activate([
            restoreButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 228.5.scale),
            restoreButton.centerYAnchor.constraint(equalTo: privacyPolicyButton.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            preloader.widthAnchor.constraint(equalToConstant: 45.scale),
            preloader.heightAnchor.constraint(equalToConstant: 45.scale),
            preloader.centerXAnchor.constraint(equalTo: centerXAnchor),
            preloader.centerYAnchor.constraint(equalTo: buyButton.centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension PaygateView {
    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        view.image = UIImage(named: ScreenSize.isIphoneXFamily ? "Paygate.Image.X" : "Paygate.Image.8")
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeCloseButton() -> TapAreaButton {
        let view = TapAreaButton()
        view.setImage(UIImage(named: "Paygate.Close"), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.black1)
            .font(Fonts.RobotoCondensed.medium(size: 32.scale))
            .lineHeight(44.8.scale)
            .textAlignment(.center)
        
        let view = UILabel()
        view.attributedText = "Paygate.Title".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeCell(number: Int) -> PaygateInfoCell {
        let view = PaygateInfoCell(text: "Paygate.Info\(number)".localized)
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeEnableTrialButton() -> PaygateEnableTrialButton {
        let view = PaygateEnableTrialButton()
        view.backgroundColor = UIColor.clear
        view.layer.cornerRadius = 10.scale
        view.layer.borderWidth = 2.scale
        view.layer.borderColor = Appearance.black2.withAlphaComponent(0.2).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeProductButton() -> PaygateProductButton {
        let view = PaygateProductButton()
        view.layer.cornerRadius = 10.scale
        view.layer.borderWidth = 2.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeBestOfferView() -> PaygateBestOfferView {
        let view = PaygateBestOfferView()
        view.layer.cornerRadius = 10.scale
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeBuyButton() -> UIButton {
        let view = UIButton()
        view.layer.cornerRadius = 20.scale
        view.backgroundColor = Appearance.primary1
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeInfoView() -> PaygateInfoView {
        let view = PaygateInfoView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeActionButton(text: String) -> TapAreaButton {
        let attrs = TextAttributes()
            .textColor(Appearance.black2)
            .font(Fonts.RobotoCondensed.regular(size: 14.scale))
        
        let view = TapAreaButton()
        view.backgroundColor = UIColor.clear
        view.setAttributedTitle(text.attributed(with: attrs), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makePreloader() -> UIActivityIndicatorView {
        let view = UIActivityIndicatorView()
        view.style = .large
        view.color = UIColor.white
        view.hidesWhenStopped = true
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
