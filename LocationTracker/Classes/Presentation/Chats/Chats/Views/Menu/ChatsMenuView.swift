//
//  ChatsMenuView.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 05.02.2024.
//

import UIKit

final class ChatsMenuView: UIView {
    lazy var dimmedView = makeDimmedView()
    lazy var container = makeContainer()
    lazy var deleteButton = makeDeleteButton()
    
    lazy var containerYConstraint = NSLayoutConstraint()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Make constraints
private extension ChatsMenuView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            dimmedView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dimmedView.trailingAnchor.constraint(equalTo: trailingAnchor),
            dimmedView.bottomAnchor.constraint(equalTo: bottomAnchor),
            dimmedView.topAnchor.constraint(equalTo: topAnchor)
        ])
        
        containerYConstraint = container.topAnchor.constraint(equalTo: bottomAnchor)
        NSLayoutConstraint.activate([
            containerYConstraint,
            container.heightAnchor.constraint(equalToConstant: 94.scale),
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            deleteButton.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            deleteButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            deleteButton.heightAnchor.constraint(equalToConstant: 56.scale),
            deleteButton.topAnchor.constraint(equalTo: container.topAnchor, constant: 16.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension ChatsMenuView {
    func makeDimmedView() -> UIView {
        let view = UIView()
        view.alpha = 0
        view.backgroundColor = UIColor.black
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.background1
        view.layer.cornerRadius = 20.scale
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeDeleteButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.red)
            .textAlignment(.left)
            .font(Fonts.RobotoCondensed.regular(size: 16.scale))
        
        let view = UIButton()
        view.contentHorizontalAlignment = .left
        view.setAttributedTitle("Chats.Menu.Delete".localized.attributed(with: attrs), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
}
