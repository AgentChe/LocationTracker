//
//  ChatsTableCell.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 02.02.2024.
//

import UIKit
import Kingfisher

final class ChatsTableCell: UITableViewCell {
    var didTapMenu: (() -> Void)?
    
    lazy var photoView = makeImageView()
    lazy var photoPlaceholderLabel = makeLabel()
    lazy var contentLabel = makeLabel()
    lazy var timeLabel = makeLabel()
    lazy var menuButton = makeMenuButton()
    lazy var separator = makeSeparator()
    
    private lazy var messageAttrs = TextAttributes()
        .textColor(Appearance.black1.withAlphaComponent(0.6))
        .font(Fonts.RobotoCondensed.regular(size: 16.scale))
        .lineHeight(22.4.scale)
        .textAlignment(.left)
        .lineBreakMode(.byTruncatingTail)
    private lazy var nameAttrs = TextAttributes()
        .textColor(Appearance.black2)
        .font(Fonts.RobotoCondensed.medium(size: 16.scale))
        .lineHeight(22.4.scale)
        .textAlignment(.left)
        .lineBreakMode(.byTruncatingTail)
    private lazy var placeholderPhotoAttrs = TextAttributes()
        .textColor(Appearance.primary1)
        .font(Fonts.RobotoCondensed.bold(size: 16.scale))
        .lineHeight(22.4.scale)
        .textAlignment(.center)
    private lazy var timeAttrs = TextAttributes()
        .textColor(Appearance.black1.withAlphaComponent(0.6))
        .font(Fonts.RobotoCondensed.regular(size: 12.scale))
        .lineHeight(16.scale)
        .textAlignment(.right)
        .lineBreakMode(.byTruncatingTail)
    
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
    }
}

// MARK: Public
extension ChatsTableCell {
    func setup(element: ChatsTableElement) {
        let photoUrl = element.partner.photoUrl
        photoView.backgroundColor = photoUrl == nil ? Appearance.green.withAlphaComponent(0.7) : UIColor.clear
        photoPlaceholderLabel.isHidden = photoUrl != nil
        
        if let photoUrl {
            photoView.kf.setImage(with: photoUrl)
        } else if let firstCharacter = element.partner.name.first {
            let string = String(firstCharacter)
            photoPlaceholderLabel.attributedText = string.attributed(with: placeholderPhotoAttrs)
        }
        
        let content = NSMutableAttributedString()
        content.append(element.partner.name.attributed(with: nameAttrs))
        if let body = element.chat.lastMessage?.body {
            content.append("\n".attributed(with: nameAttrs))
            content.append(body.attributed(with: messageAttrs))
        }
        contentLabel.attributedText = content
        
        timeLabel.attributedText = element.time?.attributed(with: timeAttrs)
    }
}

// MARK: Private
private extension ChatsTableCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
        
        contentLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        contentLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        timeLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        timeLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    
    @objc
    func menuTapped() {
        didTapMenu?()
    }
}

// MARK: Make constraints
private extension ChatsTableCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            photoView.widthAnchor.constraint(equalToConstant: 60.scale),
            photoView.heightAnchor.constraint(equalToConstant: 60.scale),
            photoView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            photoView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale)
        ])
        
        NSLayoutConstraint.activate([
            photoPlaceholderLabel.centerXAnchor.constraint(equalTo: photoView.centerXAnchor),
            photoPlaceholderLabel.centerYAnchor.constraint(equalTo: photoView.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            contentLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 92.scale),
            contentLabel.trailingAnchor.constraint(equalTo: timeLabel.leadingAnchor, constant: -16.scale),
            contentLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24.scale),
            contentLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24.scale)
        ])
        
        NSLayoutConstraint.activate([
            timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -56.scale),
            timeLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            menuButton.widthAnchor.constraint(equalToConstant: 24.scale),
            menuButton.heightAnchor.constraint(equalToConstant: 24.scale),
            menuButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            menuButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1.scale),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension ChatsTableCell {
    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.layer.borderWidth = 1.scale
        view.layer.borderColor = Appearance.background1.cgColor
        view.layer.cornerRadius = 20.scale
        view.layer.masksToBounds = true
        view.contentMode = .scaleAspectFill
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.numberOfLines = 2
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeMenuButton() -> TapAreaButton {
        let view = TapAreaButton()
        view.backgroundColor = UIColor.clear
        view.setImage(UIImage(named: "Chats.Menu"), for: .normal)
        view.addTarget(self, action: #selector(menuTapped), for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeSeparator() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.background2
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
}
