//
//  ProfileEditCell.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 26.12.2023.
//

import UIKit

final class ProfileEditCell: UITableViewCell {
    var didEdit: (() -> Void)?
    
    lazy var editButton = makeEditButton()
    lazy var photoView = makePhotoView()
    lazy var placeholderPhotoLabel = makeLabel()
    lazy var nameLabel = makeLabel()
    
    private lazy var nameAttrs = TextAttributes()
        .textColor(Appearance.black2)
        .font(Fonts.RobotoCondensed.medium(size: 24.scale))
        .lineHeight(33.6.scale)
        .textAlignment(.center)
    private lazy var placeholderPhotoAttrs = TextAttributes()
        .textColor(Appearance.primary1)
        .font(Fonts.RobotoCondensed.bold(size: 16.scale))
        .lineHeight(22.4.scale)
        .textAlignment(.left)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        photoView.kf.cancelDownloadTask()
        photoView.image = nil
        
        placeholderPhotoLabel.text = ""
    }
}

// MARK: Public
extension ProfileEditCell {
    func setup(element: ProfileEditElement) {
        nameLabel.attributedText = element.name.attributed(with: nameAttrs)
        
        photoView.backgroundColor = element.color
        placeholderPhotoLabel.isHidden = element.photoUrl != nil
        
        if let url = element.photoUrl {
            photoView.kf.setImage(with: url)
        } else if let firstCharacter = element.name.first {
            let string = String(firstCharacter)
            placeholderPhotoLabel.attributedText = string.attributed(with: placeholderPhotoAttrs)
        }
    }
}

// MARK: Private
private extension ProfileEditCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
    
    @objc
    func didEditTapped() {
        didEdit?()
    }
}

// MARK: Make constraints
private extension ProfileEditCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            editButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            editButton.bottomAnchor.constraint(equalTo: nameLabel.topAnchor, constant: -132.scale)
        ])
        
        NSLayoutConstraint.activate([
            photoView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            photoView.bottomAnchor.constraint(equalTo: nameLabel.topAnchor, constant: -16.scale),
            photoView.widthAnchor.constraint(equalToConstant: 100.scale),
            photoView.heightAnchor.constraint(equalToConstant: 100.scale)
        ])
        
        NSLayoutConstraint.activate([
            placeholderPhotoLabel.centerXAnchor.constraint(equalTo: photoView.centerXAnchor),
            placeholderPhotoLabel.centerYAnchor.constraint(equalTo: photoView.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 157.scale),
            nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension ProfileEditCell {
    func makeEditButton() -> TapAreaButton {
        let attrs = TextAttributes()
            .textColor(Appearance.primary1)
            .font(Fonts.RobotoCondensed.medium(size: 18.scale))
        
        let view = TapAreaButton()
        view.backgroundColor = UIColor.clear
        view.setAttributedTitle("Profile.Edit".localized.attributed(with: attrs), for: .normal)
        view.addTarget(self, action: #selector(didEditTapped), for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makePhotoView() -> UIImageView {
        let view = UIImageView()
        view.layer.cornerRadius = 40.scale
        view.layer.masksToBounds = true
        view.contentMode = .scaleAspectFill
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
}
