//
//  EditPlaceView.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 11.01.2024.
//

import UIKit

final class EditPlaceView: UIView {
    lazy var addressPlaceholderLabel = makeAddressPlaceholderLabel()
    lazy var addressLabel = makeAddressLabel()
    lazy var deleteButton = makeDeleteButton()
    lazy var preloader = makePreloader()
    
    private lazy var attrs = TextAttributes()
        .textColor(Appearance.black2)
        .font(Fonts.RobotoCondensed.regular(size: 16.scale))
        .lineHeight(22.4.scale)
        .textAlignment(.left)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension EditPlaceView {
    func setup(address: String) {
        addressLabel.attributedText = address.attributed(with: attrs)
    }
}

// MARK: Private
private extension EditPlaceView {
    func initialize() {
        backgroundColor = Appearance.background1
    }
}

// MARK: Make constraints
private extension EditPlaceView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            addressPlaceholderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            addressPlaceholderLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16.scale)
        ])
        
        NSLayoutConstraint.activate([
            addressLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            addressLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            addressLabel.topAnchor.constraint(equalTo: addressPlaceholderLabel.bottomAnchor, constant: 8.scale)
        ])
        
        NSLayoutConstraint.activate([
            deleteButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            deleteButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            deleteButton.heightAnchor.constraint(equalToConstant: 56.scale),
            deleteButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: ScreenSize.isIphoneXFamily ? -60.scale : -30.scale)
        ])
        
        NSLayoutConstraint.activate([
            preloader.widthAnchor.constraint(equalToConstant: 45.scale),
            preloader.heightAnchor.constraint(equalToConstant: 45.scale),
            preloader.centerXAnchor.constraint(equalTo: centerXAnchor),
            preloader.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension EditPlaceView {
    func makeAddressPlaceholderLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.black1)
            .font(Fonts.RobotoCondensed.regular(size: 16.scale))
            .lineHeight(22.4.scale)
            .textAlignment(.left)
        
        let view = UILabel()
        view.attributedText = "EditPlace.Address".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeAddressLabel() -> PaddingLabel {
        let view = PaddingLabel()
        view.numberOfLines = 0
        view.backgroundColor = Appearance.white
        view.layer.cornerRadius = 10.scale
        view.layer.borderWidth = 1.scale
        view.layer.borderColor = Appearance.background2.cgColor
        view.insets = UIEdgeInsets(value: 16.scale)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeDeleteButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.primary1)
            .font(Fonts.RobotoCondensed.medium(size: 16.scale))
        
        let view = UIButton()
        view.setAttributedTitle("EditPlace.Delete".localized.attributed(with: attrs), for: .normal)
        view.backgroundColor = Appearance.primary2
        view.layer.cornerRadius = 20.scale
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
