//
//  MemberInfoCell.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 27.12.2023.
//

import UIKit

final class MemberInfoCell: UITableViewCell {
    lazy var photoView = makeImageView()
    lazy var placeholderPhotoLabel = makePlaceholderLabel()
    lazy var container = makeContainer()
    lazy var nameLabel = makeLabel()
    lazy var batteryIconView = makeBatteryIconView()
    lazy var batteryLabel = makeLabel()
    
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
    private lazy var batteryAttrs = TextAttributes()
        .textColor(Appearance.primary1)
        .font(Fonts.RobotoCondensed.regular(size: 14.scale))
        .lineHeight(19.6.scale)
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
extension MemberInfoCell {
    func setup(element: MemberInfoElement) {
        updatePhoto(element: element)
        updateBattery(element: element)
        
        nameLabel.attributedText = element.name.attributed(with: nameAttrs)
    }
}

// MARK: Private
private extension MemberInfoCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
    
    func updatePhoto(element: MemberInfoElement) {
        photoView.backgroundColor = element.color
        placeholderPhotoLabel.isHidden = element.photoUrl != nil
        
        if let url = element.photoUrl {
            photoView.kf.setImage(with: url)
        } else if let firstCharacter = element.name.first {
            let string = String(firstCharacter)
            placeholderPhotoLabel.attributedText = string.attributed(with: placeholderPhotoAttrs)
        }
    }
    
    func updateBattery(element: MemberInfoElement) {
        batteryIconView.isHidden = element.batteryLevel == nil
        batteryLabel.isHidden = element.batteryLevel == nil
        
        if let battery = element.batteryLevel {
            batteryLabel.attributedText = "\(battery)%".attributed(with: batteryAttrs)
        } else {
            batteryLabel.attributedText = "-".attributed(with: batteryAttrs)
        }
    }
}

// MARK: Make constraints
private extension MemberInfoCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            photoView.widthAnchor.constraint(equalToConstant: 60.scale),
            photoView.heightAnchor.constraint(equalToConstant: 60.scale),
            photoView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            photoView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale)
        ])
        
        NSLayoutConstraint.activate([
            placeholderPhotoLabel.centerXAnchor.constraint(equalTo: photoView.centerXAnchor),
            placeholderPhotoLabel.centerYAnchor.constraint(equalTo: photoView.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 92.scale),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            container.topAnchor.constraint(equalTo: contentView.topAnchor),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            nameLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 4.scale)
        ])
        
        NSLayoutConstraint.activate([
            batteryIconView.widthAnchor.constraint(equalToConstant: 24.scale),
            batteryIconView.heightAnchor.constraint(equalToConstant: 24.scale),
            batteryIconView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            batteryIconView.centerYAnchor.constraint(equalTo: batteryLabel.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            batteryLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 28.scale),
            batteryLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            batteryLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4.scale),
            batteryLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -4.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension MemberInfoCell {
    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 20.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makePlaceholderLabel() -> UILabel {
        let view = UILabel()
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
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
        view.image = UIImage(named: "Member.Battery")
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
}
