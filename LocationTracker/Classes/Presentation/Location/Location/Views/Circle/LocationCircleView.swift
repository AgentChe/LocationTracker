//
//  LocationCircleView.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 25.12.2023.
//

import UIKit

final class LocationCircleView: UIView {
    lazy var separator = makeSeparator()
    lazy var swipeView = makeSwipeView()
    lazy var swipeArea = makeSwipeArea()
    lazy var tableView = makeTableView()
    lazy var preloader = makePreloader()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Make constraints
private extension LocationCircleView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            separator.leadingAnchor.constraint(equalTo: leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor),
            separator.topAnchor.constraint(equalTo: topAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1.scale)
        ])
        
        NSLayoutConstraint.activate([
            swipeView.widthAnchor.constraint(equalToConstant: 32.scale),
            swipeView.heightAnchor.constraint(equalToConstant: 4.scale),
            swipeView.centerXAnchor.constraint(equalTo: centerXAnchor),
            swipeView.topAnchor.constraint(equalTo: topAnchor, constant: 4.scale)
        ])
        
        NSLayoutConstraint.activate([
            swipeArea.leadingAnchor.constraint(equalTo: leadingAnchor),
            swipeArea.trailingAnchor.constraint(equalTo: trailingAnchor),
            swipeArea.topAnchor.constraint(equalTo: topAnchor),
            swipeArea.heightAnchor.constraint(equalToConstant: 32.scale)
        ])
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.topAnchor.constraint(equalTo: swipeArea.bottomAnchor, constant: 2.scale),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2.scale)
        ])
        
        NSLayoutConstraint.activate([
            preloader.centerXAnchor.constraint(equalTo: centerXAnchor),
            preloader.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension LocationCircleView {
    func makeSeparator() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.background2
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeSwipeView() -> UIView {
        let view = UIView()
        view.layer.cornerRadius = 1.scale
        view.backgroundColor = Appearance.background2
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeSwipeArea() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTableView() -> LocationCircleTableView {
        let view = LocationCircleTableView()
        view.separatorStyle = .none
        view.showsVerticalScrollIndicator = false
        view.contentInset = UIEdgeInsets(b: 16.scale)
        view.setContentOffset(CGPoint.zero, animated: true)
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makePreloader() -> UIActivityIndicatorView {
        let view = UIActivityIndicatorView()
        view.hidesWhenStopped = true
        view.style = .large
        view.color = Appearance.primary1
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
