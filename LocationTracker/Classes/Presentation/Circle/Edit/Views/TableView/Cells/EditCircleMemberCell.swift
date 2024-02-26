//
//  EditCircleMemberCell.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 12.12.2023.
//

import UIKit
import Kingfisher

final class EditCircleMemberCell: UITableViewCell {
    var didTapDelete: (() -> Void)?
    
    lazy var container = makeContainer()
    lazy var photoView = makeImageView()
    lazy var placeholderPhotoLabel = makeLabel()
    lazy var nameLabel = makeLabel()
    lazy var deleteIconButton = makeDeleteIconButton()
    
    private lazy var nameAttrs = TextAttributes()
        .textColor(Appearance.black2)
        .font(Fonts.RobotoCondensed.medium(size: 16.scale))
        .lineHeight(22.4.scale)
        .textAlignment(.left)
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
extension EditCircleMemberCell {
    func setup(element: EditCircleMember) {
        nameLabel.attributedText = element.member.name.attributed(with: nameAttrs)
        
        photoView.backgroundColor = element.color
        placeholderPhotoLabel.isHidden = element.member.photo != nil
        
        if let url = element.member.photo?.url {
            photoView.kf.setImage(with: url)
        } else if let firstCharacter = element.member.name.first {
            let string = String(firstCharacter)
            placeholderPhotoLabel.attributedText = string.attributed(with: placeholderPhotoAttrs)
        }
    }
}

// MARK: Private
private extension EditCircleMemberCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
    
    @objc
    func tap() {
        didTapDelete?()
    }
}

// MARK: Make constraints
private extension EditCircleMemberCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16.scale),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            photoView.widthAnchor.constraint(equalToConstant: 48.scale),
            photoView.heightAnchor.constraint(equalToConstant: 48.scale),
            photoView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            photoView.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            placeholderPhotoLabel.centerXAnchor.constraint(equalTo: photoView.centerXAnchor),
            placeholderPhotoLabel.centerYAnchor.constraint(equalTo: photoView.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 76.scale),
            nameLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -48.scale),
            nameLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 32.scale),
            nameLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -32.scale)
        ])
        
        NSLayoutConstraint.activate([
            deleteIconButton.widthAnchor.constraint(equalToConstant: 24.scale),
            deleteIconButton.heightAnchor.constraint(equalToConstant: 24.scale),
            deleteIconButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            deleteIconButton.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension EditCircleMemberCell {
    func makeContainer() -> UIView {
        let view = UIView()
        view.layer.cornerRadius = 20.scale
        view.backgroundColor = Appearance.white
        view.layer.borderWidth = 1.scale
        view.layer.borderColor = Appearance.background2.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.layer.cornerRadius = 20.scale
        view.layer.masksToBounds = true
        view.layer.borderWidth = 1.scale
        view.layer.borderColor = Appearance.background2.cgColor
        view.contentMode = .scaleAspectFill
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeDeleteIconButton() -> TapAreaButton {
        let view = TapAreaButton()
        view.setImage(UIImage(named: "EditCircle.DeleteMember"), for: .normal)
        view.addTarget(self, action: #selector(tap), for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
}
