//
//  ProfileMenuCell.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 26.12.2023.
//

import UIKit

final class ProfileMenuCell: UITableViewCell {
    var didTap: ((ProfileMenuButton.MenuItem) -> Void)?
    
    lazy var container = makeContainer()
    lazy var savedPlacesButton = makeItemButton(item: .savedPlaces)
    lazy var pinButton = makeItemButton(item: .pin)
    lazy var settingsButton = makeItemButton(item: .settings)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension ProfileMenuCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
    
    @objc
    func didTap(sender: UIButton) {
        guard let menuButton = sender as? ProfileMenuButton else {
            return
        }
        
        didTap?(menuButton.menuItem)
    }
}

// MARK: Make constraints
private extension ProfileMenuCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24.scale),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            savedPlacesButton.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            savedPlacesButton.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            savedPlacesButton.topAnchor.constraint(equalTo: container.topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            pinButton.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            pinButton.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            pinButton.topAnchor.constraint(equalTo: savedPlacesButton.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            settingsButton.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            settingsButton.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            settingsButton.topAnchor.constraint(equalTo: pinButton.bottomAnchor),
            settingsButton.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension ProfileMenuCell {
    func makeContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.white
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 10.scale
        view.layer.borderWidth = 1.scale
        view.layer.borderColor = Appearance.background2.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeItemButton(item: ProfileMenuButton.MenuItem) -> ProfileMenuButton {
        let view = ProfileMenuButton(menuItem: item)
        view.backgroundColor = UIColor.clear
        view.addTarget(self, action: #selector(didTap(sender:)), for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
}
