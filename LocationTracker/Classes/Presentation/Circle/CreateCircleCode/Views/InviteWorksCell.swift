//
//  InviteWorksCell.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 08.12.2023.
//

import UIKit

final class InviteWorksCell: UIView {
    lazy var imageView = makeImageView()
    lazy var label = makeLabel()
    
    private let iconName: String
    private let text: String
    
    init(iconName: String, text: String) {
        self.iconName = iconName
        self.text = text
        
        super.init(frame: .zero)
        
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Make constraints
private extension InviteWorksCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 48.scale),
            imageView.heightAnchor.constraint(equalToConstant: 48.scale),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 80.scale),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 2.scale),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension InviteWorksCell {
    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        view.image = UIImage(named: iconName)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.black1)
            .font(Fonts.RobotoCondensed.regular(size: 16.scale))
            .lineHeight(22.4.scale)
            .textAlignment(.left)
        
        let view = UILabel()
        view.attributedText = text.attributed(with: attrs)
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
