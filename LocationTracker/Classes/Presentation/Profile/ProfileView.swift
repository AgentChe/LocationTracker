//
//  ProfileView.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 21.12.2023.
//

import UIKit

final class ProfileView: UIView {
    lazy var scrollView = makeScrollView() // TODO: remove
    lazy var resetButton = makeReset() // TODO: remove
    lazy var label = makeLabel() // TODO: remove
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension ProfileView {
    func initialize() {
        backgroundColor = Appearance.background1
    }
    
    // TODO: remove
    @objc
    func reset() {
        UserDefaults.standard.removeObject(forKey: "test")
    }
}

// MARK: Make constraints
private extension ProfileView {
    func makeConstraints() {
        // TODO: remove
        NSLayoutConstraint.activate([
            resetButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            resetButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16.scale)
        ])
        
        // TODO: remove
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: resetButton.bottomAnchor, constant: 16.scale),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // TODO: remove
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            label.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16.scale),
            label.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16.scale),
            label.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16.scale),
            label.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension ProfileView {
    // TODO: remove
    func makeScrollView() -> UIScrollView {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = false
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    // TODO: remove
    func makeReset() -> UIButton {
        let view = UIButton()
        view.setTitleColor(Appearance.black2, for: .normal)
        view.setTitle("Reset", for: .normal)
        view.addTarget(self, action: #selector(reset), for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    // TODO: remove
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.numberOfLines = 0
        view.text = UserDefaults.standard.string(forKey: "test")
        view.textColor = Appearance.black2
        view.font = Fonts.RobotoCondensed.regular(size: 12.scale)
        view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(view)
        return view
    }
}
