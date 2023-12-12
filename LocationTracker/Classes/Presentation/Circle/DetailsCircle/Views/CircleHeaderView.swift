//
//  CircleHeaderView.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 11.12.2023.
//

import UIKit

final class CircleHeaderView: UIButton {
    lazy var label = makeLabel()
    lazy var iconView = makeIconView()
    
    private lazy var attrs = TextAttributes()
        .textColor(Appearance.primary1)
        .font(Fonts.RobotoCondensed.medium(size: 18.scale))
        .lineHeight(25.2.scale)
        .textAlignment(.center)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension CircleHeaderView {
    func setup(name: String) {
        label.attributedText = name.attributed(with: attrs)
    }
}

// MARK: Make constraints
private extension CircleHeaderView {
    func makeConstraint() {
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 48.scale),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -48.scale),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 16.scale),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16.scale)
        ])
        
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 24.scale),
            iconView.heightAnchor.constraint(equalToConstant: 24.scale),
            iconView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension CircleHeaderView {
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeIconView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        view.image = UIImage(named: "CircleDetails.Arrow.Down")
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
