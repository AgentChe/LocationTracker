//
//  CirclesTableCell.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 06.12.2023.
//

import UIKit
import Kingfisher

final class CirclesTableCell: UITableViewCell {
    lazy var container = makeContainer()
    lazy var iconView = makeImageView()
    lazy var placeholderPhotoLabel = makePlaceholderPhotoLabel()
    lazy var labelsContainer = makeLabelsContainer()
    lazy var nameLabel = makeLabel()
    lazy var membersCountLabel = makeLabel()
    
    private lazy var nameAttrs = TextAttributes()
        .textColor(Appearance.black2)
        .font(Fonts.RobotoCondensed.medium(size: 16.scale))
        .lineHeight(22.4.scale)
        .textAlignment(.left)
    private lazy var membersCountAttrs = TextAttributes()
        .textColor(Appearance.black1)
        .font(Fonts.RobotoCondensed.regular(size: 16.scale))
        .lineHeight(22.4.scale)
        .textAlignment(.left)
    private lazy var placeholderPhotoAttrs = TextAttributes()
        .textColor(Appearance.primary1)
        .font(Fonts.RobotoCondensed.bold(size: 16.scale))
        .lineHeight(22.4.scale)
        .textAlignment(.center)
    
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
        
        iconView.kf.cancelDownloadTask()
        iconView.image = nil
        
        placeholderPhotoLabel.text = ""
    }
}

// MARK: Public
extension CirclesTableCell {
    func setup(element: CirclesTableElement) {
        nameLabel.attributedText = element.circle.name.attributed(with: nameAttrs)
        
        let membersCount = String(format: "Circles.MembersCount".localized, element.circle.members.count)
        membersCountLabel.attributedText = membersCount.attributed(with: membersCountAttrs)
        
        iconView.backgroundColor = element.color
        placeholderPhotoLabel.isHidden = element.circle.imageUrl != nil
        
        if let url = element.circle.imageUrl {
            iconView.kf.setImage(with: url)
        } else if let firstCharacter = element.circle.name.first {
            let string = String(firstCharacter)
            placeholderPhotoLabel.attributedText = string.attributed(with: placeholderPhotoAttrs)
        }
    }
}

// MARK: Private
private extension CirclesTableCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension CirclesTableCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8.scale),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8.scale)
        ])
        
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 48.scale),
            iconView.heightAnchor.constraint(equalToConstant: 48.scale),
            iconView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            iconView.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            placeholderPhotoLabel.centerXAnchor.constraint(equalTo: iconView.centerXAnchor),
            placeholderPhotoLabel.centerYAnchor.constraint(equalTo: iconView.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            labelsContainer.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 76.scale),
            labelsContainer.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            labelsContainer.topAnchor.constraint(equalTo: container.topAnchor, constant: 16.scale),
            labelsContainer.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16.scale)
        ])
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: labelsContainer.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: labelsContainer.trailingAnchor),
            nameLabel.topAnchor.constraint(equalTo: labelsContainer.topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            membersCountLabel.leadingAnchor.constraint(equalTo: labelsContainer.leadingAnchor),
            membersCountLabel.trailingAnchor.constraint(equalTo: labelsContainer.trailingAnchor),
            membersCountLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4.scale),
            membersCountLabel.bottomAnchor.constraint(equalTo: labelsContainer.bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension CirclesTableCell {
    func makeContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.white
        view.layer.cornerRadius = 10.scale
        view.layer.borderColor = Appearance.primary1.cgColor
        view.layer.borderWidth = 1.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.layer.cornerRadius = 24.scale
        view.layer.masksToBounds = true
        view.contentMode = .scaleAspectFill
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makePlaceholderPhotoLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeLabelsContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        labelsContainer.addSubview(view)
        return view
    }
}
