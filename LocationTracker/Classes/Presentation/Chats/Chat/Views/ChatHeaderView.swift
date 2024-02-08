//
//  ChatHeaderView.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 08.02.2024.
//

import UIKit

final class ChatHeaderView: UIView {
    lazy var partnerLabel = makeLabel()
    lazy var closeButton = makeCloseButton()
    
    private lazy var attrs = TextAttributes()
        .textColor(Appearance.black2)
        .font(Fonts.RobotoCondensed.medium(size: 18.scale))
        .lineHeight(25.2.scale)
        .textAlignment(.center)
        .lineBreakMode(.byTruncatingTail)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension ChatHeaderView {
    func setup(partner: String) {
        partnerLabel.attributedText = partner.attributed(with: attrs)
    }
}

// MARK: Make constraints
private extension ChatHeaderView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            partnerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 48.scale),
            partnerLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -48.scale),
            partnerLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            partnerLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            closeButton.widthAnchor.constraint(equalToConstant: 24.scale),
            closeButton.heightAnchor.constraint(equalToConstant: 24.scale),
            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            closeButton.centerYAnchor.constraint(equalTo: partnerLabel.centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension ChatHeaderView {
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeCloseButton() -> TapAreaButton {
        let view = TapAreaButton()
        view.setImage(UIImage(named: "Chat.Close"), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
