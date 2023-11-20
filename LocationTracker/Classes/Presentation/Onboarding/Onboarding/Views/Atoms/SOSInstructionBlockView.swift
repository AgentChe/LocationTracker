//
//  SOSInstructionBlockView.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 20.11.2023.
//

import UIKit

final class SOSInstructionBlockView: UIView {
    lazy var imageView = makeImageView()
    lazy var label = makeLabel()
    
    private let imageName: String
    private let text: String
    
    init(imageName: String, text: String) {
        self.imageName = imageName
        self.text = text
        
        super.init(frame: .zero)
        
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Make constraints
private extension SOSInstructionBlockView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 238.scale),
            imageView.heightAnchor.constraint(equalToConstant: 167.scale),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 183.scale),
            label.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension SOSInstructionBlockView {
    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        view.image = UIImage(named: imageName)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeLabel() -> PaddingLabel {
        let attrs = TextAttributes()
            .textColor(Appearance.primary1)
            .font(Fonts.RobotoCondensed.medium(size: 15.scale))
            .lineHeight(25.2.scale)
            .textAlignment(.center)
        
        let view = PaddingLabel()
        view.insets = UIEdgeInsets(value: 16.scale)
        view.numberOfLines = 0
        view.attributedText = text.attributed(with: attrs)
        view.backgroundColor = Appearance.primary2
        view.layer.cornerRadius = 10.scale
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
