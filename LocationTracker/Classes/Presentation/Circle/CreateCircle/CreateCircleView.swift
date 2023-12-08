//
//  CreateCircleView.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 06.12.2023.
//

import UIKit

final class CreateCircleView: UIView {
    lazy var photoView = makePhotoView()
    lazy var photoDimmedView = makePhotoDimmedView()
    lazy var editView = makeEditView()
    lazy var nameField = makeTextField()
    lazy var descriptionLabel = makeDescriptionLabel()
    lazy var saveButton = makeSaveButton()
    
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
private extension CreateCircleView {
    func initialize() {
        backgroundColor = Appearance.background1
    }
}

// MARK: Make constraints
private extension CreateCircleView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            photoView.widthAnchor.constraint(equalToConstant: 100.scale),
            photoView.heightAnchor.constraint(equalToConstant: 100.scale),
            photoView.centerXAnchor.constraint(equalTo: centerXAnchor),
            photoView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 47.scale)
        ])
        
        NSLayoutConstraint.activate([
            photoDimmedView.leadingAnchor.constraint(equalTo: photoView.leadingAnchor),
            photoDimmedView.trailingAnchor.constraint(equalTo: photoView.trailingAnchor),
            photoDimmedView.topAnchor.constraint(equalTo: photoView.topAnchor),
            photoDimmedView.bottomAnchor.constraint(equalTo: photoView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            editView.widthAnchor.constraint(equalToConstant: 24.scale),
            editView.heightAnchor.constraint(equalToConstant: 24.scale),
            editView.centerXAnchor.constraint(equalTo: photoView.centerXAnchor),
            editView.centerYAnchor.constraint(equalTo: photoView.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            nameField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            nameField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            nameField.topAnchor.constraint(equalTo: photoView.bottomAnchor, constant: 24.scale)
        ])
        
        NSLayoutConstraint.activate([
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            descriptionLabel.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 16.scale)
        ])
        
        NSLayoutConstraint.activate([
            saveButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            saveButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            saveButton.heightAnchor.constraint(equalToConstant: 56.scale),
            saveButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: ScreenSize.isIphoneXFamily ? -60.scale : -30.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension CreateCircleView {
    func makePhotoView() -> UIImageView {
        let view = UIImageView()
        view.backgroundColor = Appearance.background2
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 40.scale
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makePhotoDimmedView() -> UIView {
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.backgroundColor = Appearance.black2.withAlphaComponent(0.2)
        view.layer.cornerRadius = 40.scale
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeEditView() -> UIImageView {
        let view = UIImageView()
        view.isUserInteractionEnabled = false
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.image = UIImage(named: "CreateCircle.PhotoPlaceholder")
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTextField() -> PaddingTextField {
        let placeholderAttrs = TextAttributes()
            .textColor(Appearance.black2.withAlphaComponent(0.4))
            .font(Fonts.RobotoCondensed.regular(size: 16.scale))
            .lineHeight(22.4.scale)
        let textAttrs = TextAttributes()
            .textColor(Appearance.black2)
            .font(Fonts.RobotoCondensed.regular(size: 16.scale))
            .lineHeight(22.4.scale)
        
        let view = PaddingTextField()
        view.textPadding = UIEdgeInsets(value: 16.scale)
        view.attributedPlaceholder = "CreateCircle.NamePlaceholder".localized.attributed(with: placeholderAttrs)
        view.defaultTextAttributes = textAttrs.dictionary
        view.returnKeyType = .done
        view.backgroundColor = Appearance.white
        view.layer.cornerRadius = 10.scale
        view.layer.masksToBounds = true
        view.layer.borderWidth = 1.scale
        view.layer.borderColor = Appearance.background1.cgColor
        view.keyboardType = .namePhonePad
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeDescriptionLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.black1)
            .font(Fonts.RobotoCondensed.regular(size: 16.scale))
            .lineHeight(22.4.scale)
            .textAlignment(.center)
        
        let view = UILabel()
        view.numberOfLines = 0
        view.attributedText = "CreateCircle.Description".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeSaveButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.white)
            .font(Fonts.RobotoCondensed.medium(size: 16.scale))
        
        let view = UIButton()
        view.backgroundColor = Appearance.primary1
        view.layer.cornerRadius = 20.scale
        view.setAttributedTitle("CreateCircle.Button".localized.attributed(with: attrs), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
