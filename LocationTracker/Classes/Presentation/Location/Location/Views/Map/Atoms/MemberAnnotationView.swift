//
//  MemberAnnotationView.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 22.12.2023.
//

import MapKit
import Kingfisher

final class MemberAnnotationView: MKAnnotationView {
    lazy var container = makeContainer()
    lazy var imageView = makeImageView()
    lazy var placeholderLabel = makeLabel()
    lazy var nameLabel = makeLabel()
    lazy var batteryIconView = makeBatteryIconView()
    lazy var batteryLabel = makeLabel()
    
    private lazy var nameAttrs = TextAttributes()
        .textColor(Appearance.black2)
        .font(Fonts.RobotoCondensed.medium(size: 14.scale))
        .lineHeight(19.6.scale)
        .textAlignment(.left)
        .lineBreakMode(.byTruncatingTail)
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

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

        makeConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: 153.scale, height: 60.scale)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        imageView.kf.cancelDownloadTask()
        imageView.image = nil
    }

    override func prepareForDisplay() {
        super.prepareForDisplay()

        guard let annotation = annotation as? MemberAnnotation else {
            return
        }
        
        nameLabel.attributedText = annotation.trackInfo.member.name.attributed(with: nameAttrs)

        imageView.backgroundColor = annotation.color
        placeholderLabel.isHidden = annotation.trackInfo.member.photoUrl != nil
        
        if let url = annotation.trackInfo.member.photoUrl {
            imageView.kf.setImage(with: url)
        } else if let firstCharacter = annotation.trackInfo.member.name.first {
            let string = String(firstCharacter)
            placeholderLabel.attributedText = string.attributed(with: placeholderPhotoAttrs)
        }
        
        batteryIconView.isHidden = annotation.trackInfo.batteryLevel == nil
        batteryLabel.isHidden = annotation.trackInfo.batteryLevel == nil
        
        if let battery = annotation.trackInfo.batteryLevel {
            batteryLabel.attributedText = "\(Int(battery))%".attributed(with: batteryAttrs)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let contentSize = intrinsicContentSize
        frame.size = intrinsicContentSize
        
        centerOffset = CGPoint(x: contentSize.width / 2, y: contentSize.height / 2)
        
        let box = CGRect(
            origin: CGPoint.zero,
            size: frame.size
        )
        let roundedRect = UIBezierPath(
            roundedRect: box,
            byRoundingCorners: [.topLeft, .topRight, .bottomLeft, .bottomRight],
            cornerRadii: CGSize(width: 5.scale, height: 5.scale)
        )
        let path = CGMutablePath()
        path.addPath(roundedRect.cgPath)

        let shape = CAShapeLayer()
        shape.path = path
        container.layer.mask = shape
    }
}

// MARK: Make constraints
private extension MemberAnnotationView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.topAnchor.constraint(equalTo: topAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 48.scale),
            imageView.heightAnchor.constraint(equalToConstant: 48.scale),
            imageView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8.scale),
            imageView.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            placeholderLabel.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            placeholderLabel.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 64.scale),
            nameLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8.scale),
            nameLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 6.scale)
        ])
        
        NSLayoutConstraint.activate([
            batteryIconView.widthAnchor.constraint(equalToConstant: 24.scale),
            batteryIconView.heightAnchor.constraint(equalToConstant: 24.scale),
            batteryIconView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 64.scale),
            batteryIconView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            batteryLabel.leadingAnchor.constraint(equalTo: batteryIconView.trailingAnchor, constant: 4.scale),
            batteryLabel.centerYAnchor.constraint(equalTo: batteryIconView.centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension MemberAnnotationView {
    func makeContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.white
        view.layer.cornerRadius = 20.scale
        view.layer.borderWidth = 1.scale
        view.layer.borderColor = Appearance.background2.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 24.scale
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
    
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
}
