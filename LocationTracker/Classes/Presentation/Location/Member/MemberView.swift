//
//  MemberView.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 27.12.2023.
//

import UIKit

final class MemberView: UIView {
    lazy var dimmedView = makeDimmedView()
    lazy var container = makeContainer()
    lazy var swipeView = makeSwipeView()
    lazy var swipeArea = makeSwipeArea()
    lazy var tableView = makeTableView()
    
    private lazy var containerYConstraint = NSLayoutConstraint()
    private lazy var containerHeightConstraint = NSLayoutConstraint()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension MemberView {
    func animateShow() {
        containerYConstraint.isActive = false
        containerYConstraint = container.bottomAnchor.constraint(equalTo: bottomAnchor)
        containerYConstraint.isActive = true

        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.dimmedView.alpha = 0.6
            self?.layoutIfNeeded()
        })
    }
    
    func animateDismiss(completion: @escaping (() -> Void)) {
        containerYConstraint.isActive = false
        containerYConstraint = container.topAnchor.constraint(equalTo: bottomAnchor)
        containerYConstraint.isActive = true

        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.dimmedView.alpha = 0
            self?.layoutIfNeeded()
        }, completion: { result in
            completion()
        })
    }
    
    func large() {
        container(height: frame.height - safeAreaInsets.top)
    }
    
    func medium() {
        container(height: 400.scale)
    }
}

// MARK: Private
private extension MemberView {
    func container(height: CGFloat) {
        containerHeightConstraint.isActive = false
        containerHeightConstraint.constant = height
        containerHeightConstraint.isActive = true
        
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.layoutIfNeeded()
        })
    }
}

// MARK: Make constraints
private extension MemberView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            dimmedView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dimmedView.trailingAnchor.constraint(equalTo: trailingAnchor),
            dimmedView.bottomAnchor.constraint(equalTo: bottomAnchor),
            dimmedView.topAnchor.constraint(equalTo: topAnchor)
        ])
        
        containerYConstraint = container.topAnchor.constraint(equalTo: bottomAnchor)
        containerHeightConstraint = container.heightAnchor.constraint(equalToConstant: 400.scale)
        NSLayoutConstraint.activate([
            containerYConstraint,
            containerHeightConstraint,
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            swipeView.widthAnchor.constraint(equalToConstant: 32.scale),
            swipeView.heightAnchor.constraint(equalToConstant: 4.scale),
            swipeView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            swipeView.topAnchor.constraint(equalTo: container.topAnchor, constant: 4.scale)
        ])
        
        NSLayoutConstraint.activate([
            swipeArea.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            swipeArea.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            swipeArea.topAnchor.constraint(equalTo: container.topAnchor),
            swipeArea.heightAnchor.constraint(equalToConstant: 64.scale)
        ])
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: swipeView.bottomAnchor, constant: 2.scale),
            tableView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension MemberView {
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
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeSwipeView() -> UIView {
        let view = UIView()
        view.layer.cornerRadius = 1.scale
        view.backgroundColor = Appearance.background2
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeSwipeArea() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeTableView() -> MemberTableView {
        let view = MemberTableView()
        view.contentInset = UIEdgeInsets(vertical: 24.scale)
        view.setContentOffset(CGPoint(x: 0, y: -24.scale), animated: false)
        view.showsVerticalScrollIndicator = false
        view.separatorStyle = .none
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
}
