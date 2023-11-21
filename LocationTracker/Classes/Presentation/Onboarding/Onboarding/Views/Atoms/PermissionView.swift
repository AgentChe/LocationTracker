//
//  PermissionView.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 21.11.2023.
//

import UIKit

final class PermissionView: UIView {
    enum Permission {
        case location, push
    }
    
    lazy var titleLabel = makeTitleLabel()
    lazy var subTitleLabel = makeSubTitleLabel()
    lazy var switchView = makeSwitch()
    
    let permission: Permission
    
    init(permission: Permission) {
        self.permission = permission
        
        super.init(frame: .zero)
        
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Make constraints
private extension PermissionView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -84.scale),
            titleLabel.topAnchor.constraint(equalTo: topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            subTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            subTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -84.scale),
            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4.scale),
            subTitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            switchView.widthAnchor.constraint(equalToConstant: 51.scale),
            switchView.heightAnchor.constraint(equalToConstant: 31.scale),
            switchView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            switchView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension PermissionView {
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.black2)
            .font(Fonts.RobotoCondensed.medium(size: 18.scale))
            .lineHeight(25.2.scale)
            .textAlignment(.left)
        
        let view = UILabel()
        view.attributedText = permission.title.attributed(with: attrs)
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
        view.attributedText = permission.subTitle.attributed(with: attrs)
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeSwitch() -> UISwitch {
        let view = UISwitch()
        view.isOn = true
        view.onTintColor = Appearance.green
        view.thumbTintColor = Appearance.white
        view.tintColor = Appearance.black1
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}

// MARK: Additional
private extension PermissionView.Permission {
    var title: String {
        switch self {
        case .location:
            return "Onboarding.Permissions.Location.Title".localized
        case .push:
            return "Onboarding.Permissions.Push.Title".localized
        }
    }
    
    var subTitle: String {
        switch self {
        case .location:
            return "Onboarding.Permissions.Location.SubTitle".localized
        case .push:
            return "Onboarding.Permissions.Push.SubTitle".localized
        }
    }
}
