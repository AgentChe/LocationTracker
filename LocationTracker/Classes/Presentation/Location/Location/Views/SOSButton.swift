//
//  SOSButton.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 16.01.2024.
//

import UIKit

final class SOSButton: TapAreaButton {
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
        
        label.layer.cornerRadius = label.bounds.height / 2
    }
}

// MARK: Public
extension SOSButton {
    func setup(sos: Bool) {
        backgroundColor = sos ? Appearance.red.withAlphaComponent(0.4) : UIColor.clear
    }
}

// MARK: Private
private extension SOSButton {
    func initialize() {
        layer.cornerRadius = 20.scale
        layer.masksToBounds = true
    }
}

// MARK: Make constraints
private extension SOSButton {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4.scale),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4.scale),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 4.scale),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension SOSButton {
    func makeLabel() -> PaddingLabel {
        let attrs = TextAttributes()
            .textColor(Appearance.white)
            .font(Fonts.RobotoCondensed.medium(size: 16.scale))
            .lineHeight(22.4.scale)
            .textAlignment(.center)
        
        let view = PaddingLabel()
        view.backgroundColor = Appearance.red
        view.insets = UIEdgeInsets(vertical: 8.scale, horizontal: 16.scale)
        view.attributedText = "Location.SOS".localized.attributed(with: attrs)
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
