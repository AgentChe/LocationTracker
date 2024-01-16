//
//  SOSActiveButton.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 16.01.2024.
//

import UIKit

final class SOSActiveButton: UIButton {
    enum Action {
        case touchDown, touchUpInside, touchUpOutside
    }
    
    lazy var container = makeContainer()
    lazy var label = makeLabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = max(frame.width, frame.height) / 2
    }
}

// MARK: Private
private extension SOSActiveButton {
    func initialize() {
        backgroundColor = Appearance.red.withAlphaComponent(0.4)
    }
}

// MARK: Make constraints
private extension SOSActiveButton {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28.scale),
            container.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -28.scale),
            container.topAnchor.constraint(equalTo: topAnchor, constant: 28.scale),
            container.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -28.scale)
        ])
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension SOSActiveButton {
    func makeContainer() -> CircleView {
        let view = CircleView()
        view.isUserInteractionEnabled = false
        view.backgroundColor = Appearance.red
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.white)
            .font(Fonts.RobotoCondensed.medium(size: 64.scale))
            .lineHeight(89.6.scale)
            .textAlignment(.center)
        
        let view = UILabel()
        view.isUserInteractionEnabled = false
        view.attributedText = "SOS.Title".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
}
