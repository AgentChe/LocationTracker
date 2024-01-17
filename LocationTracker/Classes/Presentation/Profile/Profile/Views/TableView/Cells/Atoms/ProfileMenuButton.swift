//
//  ProfileMenuButton.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 26.12.2023.
//

import UIKit

final class ProfileMenuButton: UIButton {
    enum MenuItem {
        case savedPlaces, pin, settings
    }
    
    lazy var label = makeLabel()
    lazy var arrowView = makeArrowView()
    lazy var separator = makeSeparator()
    
    let menuItem: MenuItem
    
    init(menuItem: MenuItem) {
        self.menuItem = menuItem
        
        super.init(frame: .zero)
        
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Make constraints
private extension ProfileMenuButton {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -48.scale),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 16.scale),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16.scale)
        ])
        
        NSLayoutConstraint.activate([
            arrowView.widthAnchor.constraint(equalToConstant: 24.scale),
            arrowView.heightAnchor.constraint(equalToConstant: 24.scale),
            arrowView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            arrowView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            separator.leadingAnchor.constraint(equalTo: leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension ProfileMenuButton {
    func makeLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.black2)
            .font(Fonts.RobotoCondensed.regular(size: 16.scale))
            .lineHeight(22.4.scale)
            .textAlignment(.left)
        
        let view = UILabel()
        view.attributedText = menuItem.title.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeArrowView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        view.image = UIImage(named: "Profile.Arrow.Right")
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeSeparator() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.background2
        view.isHidden = menuItem == .settings
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}

// MARK: Additional
private extension ProfileMenuButton.MenuItem {
    var title: String {
        switch self {
        case .savedPlaces:
            return "Profile.SavedPlaces".localized
        case .pin:
            return "Profile.PIN".localized
        case .settings:
            return "Profile.Settings".localized
        }
    }
}
