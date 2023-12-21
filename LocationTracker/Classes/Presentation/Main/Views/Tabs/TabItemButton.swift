//
//  TabItemButton.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 21.12.2023.
//

import UIKit

final class TabItemButton: UIButton {
    lazy var marked = false {
        didSet {
            update()
        }
    }
    
    lazy var iconView = makeImageView()
    lazy var label = makeLabel()
    
    private lazy var sAttrs = TextAttributes()
        .font(Fonts.RobotoCondensed.regular(size: 13.scale))
        .textColor(Appearance.primary1)
        .lineHeight(15.6.scale)
        .textAlignment(.center)
    private lazy var dAttrs = TextAttributes()
        .font(Fonts.RobotoCondensed.regular(size: 13.scale))
        .textColor(Appearance.black2)
        .lineHeight(15.6.scale)
        .textAlignment(.center)
    
    private let code: String
    
    init(code: String) {
        self.code = code
        
        super.init(frame: .zero)
        
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension TabItemButton {
    func update() {
        alpha = marked ? 1 : 0.5
        
        iconView.image = UIImage(named: code + (marked ? ".S" : ".D"))
        
        let attrs = marked ? sAttrs : dAttrs
        label.attributedText = code.localized.attributed(with: attrs)
    }
}

// MARK: Make constraints
private extension TabItemButton {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 24.scale),
            iconView.heightAnchor.constraint(equalToConstant: 24.scale),
            iconView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconView.topAnchor.constraint(equalTo: topAnchor, constant: 8.scale)
        ])
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 6.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension TabItemButton {
    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
