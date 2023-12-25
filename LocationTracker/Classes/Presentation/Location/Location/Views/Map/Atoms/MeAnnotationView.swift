//
//  MeAnnotationView.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 22.12.2023.
//

import MapKit
import Kingfisher

final class MeAnnotationView: MKAnnotationView {
    lazy var container = makeContainer()
    lazy var imageView = makeImageView()
    lazy var placeholderLabel = makePlaceholderLabel()
    lazy var label = makeLabel()

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

        makeConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: 96.scale, height: 60.scale)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        imageView.kf.cancelDownloadTask()
        imageView.image = nil
    }

    override func prepareForDisplay() {
        super.prepareForDisplay()

        guard let annotation = annotation as? MeAnnotation else {
            return
        }

        imageView.backgroundColor = annotation.color
        placeholderLabel.isHidden = annotation.photoUrl != nil

        if let url = annotation.photoUrl {
            imageView.kf.setImage(with: url)
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
private extension MeAnnotationView {
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
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8.scale),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            placeholderLabel.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            placeholderLabel.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 64.scale),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension MeAnnotationView {
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

    func makePlaceholderLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.primary1)
            .font(Fonts.RobotoCondensed.bold(size: 16.scale))
            .lineHeight(22.4.scale)
            .textAlignment(.center)

        let view = UILabel()
        view.attributedText = "Location.M".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }

    func makeLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.black2)
            .font(Fonts.RobotoCondensed.medium(size: 14.scale))
            .lineHeight(19.6.scale)
            .textAlignment(.center)
            .lineBreakMode(.byTruncatingTail)

        let view = UILabel()
        view.attributedText = "Location.Me".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
}
