//
//  DetailsCircleMemberCell.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 11.12.2023.
//

import UIKit
import Kingfisher

final class DetailsCircleMemberCell: UITableViewCell {
    lazy var container = makeContainer()
    lazy var photoView = makeImageView()
    lazy var placeholderPhotoLabel = makeLabel()
    lazy var contentLabel = makeLabel()
    lazy var batteryIconView = makeBatteryIconView()
    lazy var batteryLabel = makeLabel()
    
    private lazy var nameAttrs = TextAttributes()
        .textColor(Appearance.black2)
        .font(Fonts.RobotoCondensed.medium(size: 16.scale))
        .lineHeight(22.4.scale)
        .textAlignment(.left)
    private lazy var addressAttrs = TextAttributes()
        .textColor(Appearance.black1)
        .font(Fonts.RobotoCondensed.regular(size: 16.scale))
        .lineHeight(22.4.scale)
        .textAlignment(.left)
    private lazy var updatedAttrs = TextAttributes()
        .textColor(Appearance.black1.withAlphaComponent(0.6))
        .font(Fonts.RobotoCondensed.regular(size: 16.scale))
        .lineHeight(22.4.scale)
        .textAlignment(.left)
    private lazy var placeholderPhotoAttrs = TextAttributes()
        .textColor(Appearance.primary1)
        .font(Fonts.RobotoCondensed.bold(size: 16.scale))
        .lineHeight(22.4.scale)
        .textAlignment(.left)
    private lazy var batteryAttrs = TextAttributes()
        .textColor(Appearance.black2)
        .font(Fonts.RobotoCondensed.regular(size: 14.scale))
        .lineHeight(19.6.scale)
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
        
        photoView.kf.cancelDownloadTask()
        photoView.image = nil
        
        placeholderPhotoLabel.text = ""
    }
}

// MARK: Public
extension DetailsCircleMemberCell {
    func setup(element: DetailsCircleTableMember) {
        updatePhoto(element: element)
        updateBattery(element: element)
        updateContent(element: element)
    }
}

// MARK: Private
private extension DetailsCircleMemberCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
    
    func updatePhoto(element: DetailsCircleTableMember) {
        let member = element.trackInfo.member
        
        photoView.backgroundColor = element.color
        placeholderPhotoLabel.isHidden = member.photoUrl != nil
        
        if let url = member.photoUrl {
            photoView.kf.setImage(with: url)
        } else if let firstCharacter = member.name.first {
            let string = String(firstCharacter)
            placeholderPhotoLabel.attributedText = string.attributed(with: placeholderPhotoAttrs)
        }
    }
    
    func updateBattery(element: DetailsCircleTableMember) {
        batteryIconView.isHidden = element.trackInfo.batteryLevel == nil
        batteryLabel.isHidden = element.trackInfo.batteryLevel == nil
        
        if let battery = element.trackInfo.batteryLevel {
            batteryLabel.attributedText = "\(Int(battery))%".attributed(with: batteryAttrs)
        }
    }
    
    func updateContent(element: DetailsCircleTableMember) {
        let result = NSMutableAttributedString()
        
        let name = element.me ? "DetailsCircle.Me".localized : element.trackInfo.member.name
        result.append(name.attributed(with: nameAttrs))
        
        if let address = element.address {
            result.append("\n".attributed(with: addressAttrs))
            result.append(address.attributed(with: addressAttrs))
        }
        
        if let lastUpdated = element.lastUpdated {
            result.append("\n".attributed(with: updatedAttrs))
            result.append(lastUpdated.attributed(with: updatedAttrs))
        }
        
        contentLabel.attributedText = result
    }
}

// MARK: Make constraints
private extension DetailsCircleMemberCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8.scale),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8.scale)
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
            contentLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 76.scale),
            contentLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -79.scale),
            contentLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 16.scale),
            contentLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16.scale)
        ])
        
        NSLayoutConstraint.activate([
            batteryIconView.widthAnchor.constraint(equalToConstant: 24.scale),
            batteryIconView.heightAnchor.constraint(equalToConstant: 24.scale),
            batteryIconView.leadingAnchor.constraint(equalTo: contentLabel.trailingAnchor, constant: 12.scale),
            batteryIconView.centerYAnchor.constraint(equalTo: contentLabel.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            batteryLabel.leadingAnchor.constraint(equalTo: batteryIconView.trailingAnchor, constant: 4.scale),
            batteryLabel.centerYAnchor.constraint(equalTo: batteryIconView.centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension DetailsCircleMemberCell {
    func makeContainer() -> UIView {
        let view = UIView()
        view.layer.cornerRadius = 10.scale
        view.layer.borderWidth = 1.scale
        view.layer.borderColor = Appearance.background2.cgColor
        view.backgroundColor = Appearance.white
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 20.scale
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
    
    func makeBatteryIconView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        view.image = UIImage(named: "CircleDetails.Battery")
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
}
