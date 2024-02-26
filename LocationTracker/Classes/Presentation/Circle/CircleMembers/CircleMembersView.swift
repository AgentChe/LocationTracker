//
//  CircleMembersView.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 09.12.2023.
//

import UIKit

final class CircleMembersView: UIView {
    lazy var closeButton = makeCloseButton()
    lazy var photosContainer = makePhotosContainer()
    lazy var titleLabel = makeLabel()
    lazy var subTitleLabel = makeLabel()
    lazy var okButton = makeOkButton()
    
    private lazy var titleAttrs = TextAttributes()
        .textColor(Appearance.black2)
        .font(Fonts.RobotoCondensed.medium(size: 24.scale))
        .lineHeight(33.6.scale)
        .textAlignment(.center)
    private lazy var subTitleAttrs = TextAttributes()
        .textColor(Appearance.black1)
        .font(Fonts.RobotoCondensed.regular(size: 16.scale))
        .lineHeight(22.4.scale)
        .textAlignment(.center)
    
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
extension CircleMembersView {
    func setup(name: String, memebers: [Member]) {
        titleLabel.attributedText = String(format: "CircleMembers.Title".localized, name).attributed(with: titleAttrs)
        subTitleLabel.attributedText = String(format: "CircleMembers.SubTitle".localized, memebers.count).attributed(with: subTitleAttrs)
        
        memebers.forEach { member in
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.layer.masksToBounds = true
            imageView.layer.cornerRadius = 40.scale
            imageView.layer.borderWidth = 1.scale
            imageView.layer.borderColor = Appearance.background1.cgColor
            imageView.translatesAutoresizingMaskIntoConstraints = false
            photosContainer.addArrangedSubview(imageView)
            
            imageView.backgroundColor = member.photo == nil ? Appearance.primary2 : UIColor.clear
            
            if let url = member.photo?.url {
                imageView.kf.setImage(with: url)
            }
            
            let size = memebers.count > 5 ? 80.scale : 100.scale

            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: size),
                imageView.heightAnchor.constraint(equalToConstant: size)
            ])
        }
    }
}

// MARK: Private
private extension CircleMembersView {
    func initialize() {
        backgroundColor = Appearance.background1
    }
}

// MARK: Make constraints
private extension CircleMembersView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            closeButton.widthAnchor.constraint(equalToConstant: 24.scale),
            closeButton.heightAnchor.constraint(equalToConstant: 24.scale),
            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            closeButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 8.scale)
        ])
        
        NSLayoutConstraint.activate([
            photosContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24.scale),
            photosContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24.scale),
            photosContainer.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -24.scale),
            photosContainer.heightAnchor.constraint(equalToConstant: 100.scale)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: ScreenSize.isIphoneXFamily ? 407.scale : 300.scale)
        ])
        
        NSLayoutConstraint.activate([
            subTitleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4.scale)
        ])
        
        NSLayoutConstraint.activate([
            okButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            okButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            okButton.heightAnchor.constraint(equalToConstant: 56.scale),
            okButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: ScreenSize.isIphoneXFamily ? -60.scale : -30.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension CircleMembersView {
    func makeCloseButton() -> TapAreaButton {
        let view = TapAreaButton()
        view.setImage(UIImage(named: "CreateCircle.Close"), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makePhotosContainer() -> UIStackView {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = -40.scale
        view.alignment = .center
        view.distribution = .fillEqually
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeOkButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.white)
            .font(Fonts.RobotoCondensed.medium(size: 16.scale))
        
        let view = UIButton()
        view.setAttributedTitle("OK".localized.attributed(with: attrs), for: .normal)
        view.backgroundColor = Appearance.primary1
        view.layer.cornerRadius = 20.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
