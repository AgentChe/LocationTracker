//
//  MemberButtonsCell.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 27.12.2023.
//

import UIKit

final class MemberButtonsCell: UITableViewCell {
    var didChatTap: (() -> Void)?
    var didGetDirectionTap: (() -> Void)?
    
    lazy var chatButton = makeChatButton()
    lazy var getDirectionButton = makeGetDirectionButton()
    
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
private extension MemberButtonsCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
    
    @objc
    func chatTapped() {
        didChatTap?()
    }
    
    @objc
    func getDirectionTapped() {
        didGetDirectionTap?()
    }
}

// MARK: Make constraints
private extension MemberButtonsCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            chatButton.widthAnchor.constraint(equalToConstant: 64.scale),
            chatButton.heightAnchor.constraint(equalToConstant: 95.scale),
            chatButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 54.scale),
            chatButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24.scale)
        ])
        
        NSLayoutConstraint.activate([
            getDirectionButton.widthAnchor.constraint(equalToConstant: 81.scale),
            getDirectionButton.heightAnchor.constraint(equalToConstant: 95.scale),
            getDirectionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -54.scale),
            getDirectionButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension MemberButtonsCell {
    func makeChatButton() -> MemberActionButton {
        let view = MemberActionButton(
            iconName: "Member.Chat",
            text: "Member.Chat".localized,
            withShadow: false
        )
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(chatTapped), for: .touchUpInside)
        contentView.addSubview(view)
        return view
    }
    
    func makeGetDirectionButton() -> MemberActionButton {
        let view = MemberActionButton(
            iconName: "Member.GetDirection",
            text: "Member.GetDirection".localized,
            withShadow: true
        )
        view.backgroundColor = UIColor.clear
        view.addTarget(self, action: #selector(getDirectionTapped), for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
}
