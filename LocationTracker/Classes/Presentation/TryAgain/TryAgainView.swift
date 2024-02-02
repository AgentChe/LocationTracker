//
//  TryAgainView.swift
//  Soccer
//
//  Created by Андрей Чернышев on 05.07.2022.
//

import UIKit

final class TryAgainView: UIView {
    lazy var imageView = makeImageView()
    lazy var titleLabel = makeTitleLabel()
    lazy var subTitleLabel = makeSubTitleLabel()
    lazy var tryAgainButton = makeButton()
    lazy var contactButton = makeContactButton()
    
    private let error: Error
    
    init(error: Error) {
        self.error = error

        super.init(frame: .zero)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension TryAgainView {
    func initialize() {
        backgroundColor = Appearance.background1
    }
    
    func errorMessage() -> String {
         guard let networkError = error as? NetworkError else {
             return "TryAgain.SubTitle".localized
         }

         switch networkError.code {
         case .serverNotAvailable, .socketUnknownError:
             return "TryAgain.SubTitle".localized
         case .logical(let message):
             return message
         }
     }
}

// MARK: Make constraints
private extension TryAgainView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 238.scale),
            imageView.heightAnchor.constraint(equalToConstant: 255.scale),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: 16.scale)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 32.scale)
        ])
        
        NSLayoutConstraint.activate([
            subTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            subTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12.scale)
        ])
        
        NSLayoutConstraint.activate([
            tryAgainButton.widthAnchor.constraint(equalToConstant: 343.scale),
            tryAgainButton.heightAnchor.constraint(equalToConstant: 56.scale),
            tryAgainButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            tryAgainButton.bottomAnchor.constraint(equalTo: contactButton.topAnchor, constant: -16.scale)
        ])
        
        NSLayoutConstraint.activate([
            contactButton.widthAnchor.constraint(equalToConstant: 343.scale),
            contactButton.heightAnchor.constraint(equalToConstant: 56.scale),
            contactButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            contactButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension TryAgainView {
    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "TryAgain.Image")
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.black2)
            .font(Fonts.RobotoCondensed.semiBold(size: 24.scale))
            .lineHeight(33.6.scale)
            .textAlignment(.center)
        
        let view = UILabel()
        view.numberOfLines = 0
        view.attributedText = "TryAgain.Title".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeSubTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.black1)
            .font(Fonts.RobotoCondensed.regular(size: 16.scale))
            .lineHeight(22.4.scale)
            .textAlignment(.center)
        
        let view = UILabel()
        view.numberOfLines = 0
        view.attributedText = errorMessage().attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.white)
            .font(Fonts.RobotoCondensed.medium(size: 16.scale))
        
        let view = UIButton()
        view.setAttributedTitle("TryAgain.Button".localized.attributed(with: attrs), for: .normal)
        view.layer.cornerRadius = 28.scale
        view.backgroundColor = Appearance.primary1
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeContactButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.primary1)
            .font(Fonts.RobotoCondensed.medium(size: 16.scale))
        
        let view = UIButton()
        view.setAttributedTitle("TryAgain.Contact".localized.attributed(with: attrs), for: .normal)
        view.layer.cornerRadius = 28.scale
        view.backgroundColor = Appearance.primary2
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
