//
//  SplashView.swift
//  Soccer
//
//  Created by Андрей Чернышев on 05.07.2022.
//

import UIKit

final class SplashView: UIView {
    lazy var imageView = makeImageView()
    lazy var preloader = makePreloader()
    lazy var preloaderLabel = makeLabel()
    
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
private extension SplashView {
    func initialize() {
        backgroundColor = Appearance.background1
    }
}

// MARK: Make constraints
private extension SplashView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 124.scale),
            imageView.heightAnchor.constraint(equalToConstant: 124.scale),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            preloader.centerXAnchor.constraint(equalTo: centerXAnchor),
            preloader.bottomAnchor.constraint(equalTo: preloaderLabel.topAnchor, constant: -16.scale)
        ])
        
        NSLayoutConstraint.activate([
            preloaderLabel.widthAnchor.constraint(equalToConstant: 45.scale),
            preloaderLabel.heightAnchor.constraint(equalToConstant: 45.scale),
            preloaderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            preloaderLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            preloaderLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: ScreenSize.isIphoneXFamily ? -34.scale : -24.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension SplashView {
    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "Splash.Image")
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
    
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
