//
//  MemberActionButton.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 27.12.2023.
//

import UIKit

final class MemberActionButton: UIButton {
    lazy var iconView = makeIconView()
    lazy var label = makeLabel()
    
    private let iconName: String
    private let text: String
    private let withShadow: Bool
    
    init(iconName: String, text: String, withShadow: Bool) {
        self.iconName = iconName
        self.text = text
        self.withShadow = withShadow
        
        super.init(frame: .zero)
        
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Make constraints
private extension MemberActionButton {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 64.scale),
            iconView.heightAnchor.constraint(equalToConstant: 64.scale),
            iconView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconView.topAnchor.constraint(equalTo: topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 8.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension MemberActionButton {
    func makeIconView() -> UIImageView {
        let view = UIImageView()
        view.isUserInteractionEnabled = false
        view.contentMode = .scaleAspectFit
        view.layer.cornerRadius = 32.scale
        view.backgroundColor = UIColor.clear
        view.image = UIImage(named: iconName)
        
        if withShadow {
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowOpacity = 0.1
            view.layer.shadowOffset = .zero
            view.layer.shadowRadius = 4.scale
        }
        
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.black2)
            .font(Fonts.RobotoCondensed.regular(size: 16.scale))
            .lineHeight(22.4.scale)
            .textAlignment(.center)
        
        let view = UILabel()
        view.isUserInteractionEnabled = false
        view.attributedText = text.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
