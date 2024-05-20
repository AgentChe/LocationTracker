//
//  PaygateEnableTrialButton.swift
//  CodeChallenge
//
//  Created by Андрей Чернышев on 20.03.2024.
//

import UIKit

final class PaygateEnableTrialButton: UIButton {
    lazy var isEnable: Bool = false {
        didSet {
            update()
        }
    }
    
    lazy var label = makeLabel()
    lazy var switchView = makeSwitchView()
    
    private lazy var attrs = TextAttributes()
        .textColor(Appearance.black1)
        .font(Fonts.RobotoCondensed.semiBold(size: 18.scale))
        .lineHeight(25.2.scale)
        .textAlignment(.left)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
        update()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension PaygateEnableTrialButton {
    func update() {
        let stringKey = isEnable ? "Paygate.FreeTrialEnabled" : "Paygate.EnableFreeTrial"
        label.attributedText = stringKey.localized.attributed(with: attrs)
        
        switchView.setOn(isEnable, animated: true)
    }
}

// MARK: Make constraints
private extension PaygateEnableTrialButton {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
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
private extension PaygateEnableTrialButton {
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeSwitchView() -> UISwitch {
        let view = UISwitch()
        view.isUserInteractionEnabled = false
        view.onTintColor = Appearance.primary1
        view.tintColor = Appearance.black1.withAlphaComponent(0.2)
        view.thumbTintColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
