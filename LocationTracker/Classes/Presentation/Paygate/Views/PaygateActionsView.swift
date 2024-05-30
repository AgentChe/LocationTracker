//
//  PaygateActionsView.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 30.05.2024.
//

import UIKit

final class PaygateActionsView: UIView {
    lazy var termsOfUseButton = makeActionButton(text: "Paygate.TermsOfUse".localized)
    lazy var privacyPolicyButton = makeActionButton(text: "Paygate.PrivacyPolicy".localized)
    lazy var restoreButton = makeActionButton(text: "Paygate.RestorePurchases".localized)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Make constraints
private extension PaygateActionsView {
    func makeConstraints() {
        switch Language() {
        case .ru, .de, .pt, .ptBr, .fr:
            let container = UIView()
            container.backgroundColor = UIColor.clear
            container.translatesAutoresizingMaskIntoConstraints = false
            addSubview(container)
            
            NSLayoutConstraint.activate([
                container.centerXAnchor.constraint(equalTo: centerXAnchor),
                container.topAnchor.constraint(equalTo: topAnchor)
            ])
            
            container.addSubview(termsOfUseButton)
            container.addSubview(privacyPolicyButton)
            addSubview(restoreButton)
            
            NSLayoutConstraint.activate([
                termsOfUseButton.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                termsOfUseButton.topAnchor.constraint(equalTo: container.topAnchor),
                termsOfUseButton.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            ])
            
            NSLayoutConstraint.activate([
                privacyPolicyButton.leadingAnchor.constraint(equalTo: termsOfUseButton.trailingAnchor, constant: 12.scale),
                privacyPolicyButton.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                privacyPolicyButton.topAnchor.constraint(equalTo: container.topAnchor),
                privacyPolicyButton.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            ])
            
            NSLayoutConstraint.activate([
                restoreButton.centerXAnchor.constraint(equalTo: centerXAnchor),
                restoreButton.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        default:
            addSubview(termsOfUseButton)
            addSubview(privacyPolicyButton)
            addSubview(restoreButton)
            
            NSLayoutConstraint.activate([
                termsOfUseButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 39.scale),
                termsOfUseButton.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
            
            NSLayoutConstraint.activate([
                privacyPolicyButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 141.scale),
                privacyPolicyButton.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
            
            NSLayoutConstraint.activate([
                restoreButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 246.scale),
                restoreButton.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
        }
    }
}

// MARK: Lazy initialization
private extension PaygateActionsView {
    func makeActionButton(text: String) -> TapAreaButton {
        let attrs = TextAttributes()
            .textColor(Appearance.black2)
            .font(Fonts.RobotoCondensed.regular(size: 14.scale))
        
        let view = TapAreaButton()
        view.backgroundColor = UIColor.clear
        view.setAttributedTitle(text.attributed(with: attrs), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
}
