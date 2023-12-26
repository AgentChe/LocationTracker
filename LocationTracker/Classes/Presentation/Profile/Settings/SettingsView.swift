//
//  SettingsView.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 26.12.2023.
//

import UIKit

final class SettingsView: UIView {
    lazy var container = makeContainer()
    lazy var contactUsButton = makeLinkButton(link: .contactUs)
    lazy var privacyPolicyButton = makeLinkButton(link: .privacyPolicy)
    lazy var termsOfUseButton = makeLinkButton(link: .termsOfUse)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension SettingsView {
    func initialize() {
        backgroundColor = Appearance.background1
    }
}

// MARK: Make constraints
private extension SettingsView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            container.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            container.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 24.scale)
        ])
        
        NSLayoutConstraint.activate([
            contactUsButton.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            contactUsButton.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            contactUsButton.topAnchor.constraint(equalTo: container.topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            privacyPolicyButton.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            privacyPolicyButton.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            privacyPolicyButton.topAnchor.constraint(equalTo: contactUsButton.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            termsOfUseButton.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            termsOfUseButton.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            termsOfUseButton.topAnchor.constraint(equalTo: privacyPolicyButton.bottomAnchor),
            termsOfUseButton.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension SettingsView {
    func makeContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.white
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 10.scale
        view.layer.borderWidth = 1.scale
        view.layer.borderColor = Appearance.background2.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeLinkButton(link: SettingsLinkButton.Link) -> SettingsLinkButton {
        let view = SettingsLinkButton(link: link)
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
}
