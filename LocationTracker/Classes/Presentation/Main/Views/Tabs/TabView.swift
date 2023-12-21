//
//  TabView.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 21.12.2023.
//

import UIKit

final class TabView: UIView {
    enum Tab {
        case location, chats, profile
    }
    
    lazy var locationItem = makeItem(code: "Tab.Location")
    lazy var chatsItem = makeItem(code: "Tab.Chats")
    lazy var profileItem = makeItem(code: "Tab.Profile")
    
    var selectedTab = Tab.location {
        didSet {
            update()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension TabView {
    func update() {
        locationItem.marked = selectedTab == .location
        chatsItem.marked = selectedTab == .chats
        profileItem.marked = selectedTab == .profile
    }
}

// MARK: Make constraints
private extension TabView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            locationItem.leadingAnchor.constraint(equalTo: leadingAnchor),
            locationItem.bottomAnchor.constraint(equalTo: bottomAnchor),
            locationItem.topAnchor.constraint(equalTo: topAnchor),
            locationItem.widthAnchor.constraint(equalTo: chatsItem.widthAnchor)
        ])
        
        NSLayoutConstraint.activate([
            chatsItem.leadingAnchor.constraint(equalTo: locationItem.trailingAnchor),
            chatsItem.bottomAnchor.constraint(equalTo: bottomAnchor),
            chatsItem.topAnchor.constraint(equalTo: topAnchor),
            chatsItem.widthAnchor.constraint(equalTo: profileItem.widthAnchor)
        ])
        
        NSLayoutConstraint.activate([
            profileItem.leadingAnchor.constraint(equalTo: chatsItem.trailingAnchor),
            profileItem.bottomAnchor.constraint(equalTo: bottomAnchor),
            profileItem.topAnchor.constraint(equalTo: topAnchor),
            profileItem.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension TabView {
    func makeItem(code: String) -> TabItemButton {
        let view = TabItemButton(code: code)
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
