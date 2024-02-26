//
//  SOSView.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 16.01.2024.
//

import UIKit
import Kingfisher

final class SOSView: UIView {
    lazy var closeButton = makeCloseButton()
    lazy var titleLabel = makeTitleLabel()
    lazy var instructionButton = makeInstructionButton()
    lazy var actionLabel = makeActionLabel()
    lazy var sosButton = makeSOSButton()
    lazy var circleLabel = makeCircleLabel()
    lazy var photosContainer = makePhotosContainer()
    lazy var pinLabel = makePINLabel()
    
    private lazy var sosWidthConstraint = NSLayoutConstraint()
    private lazy var sosHeightConstraint = NSLayoutConstraint()
    
    private lazy var actionAttrs = TextAttributes()
        .textColor(Appearance.black2)
        .font(Fonts.RobotoCondensed.regular(size: 18.scale))
        .lineHeight(25.2.scale)
        .textAlignment(.center)
    private lazy var pinTitleAttrs = TextAttributes()
        .textColor(Appearance.black1)
        .font(Fonts.RobotoCondensed.regular(size: 16.scale))
        .lineHeight(22.4.scale)
        .textAlignment(.center)
    private lazy var pinAttrs = TextAttributes()
        .textColor(Appearance.black2)
        .font(Fonts.RobotoCondensed.bold(size: 32.scale))
        .lineHeight(44.8.scale)
        .textAlignment(.center)
    
    private let circle: Circle
    
    init(circle: Circle) {
        self.circle = circle
        
        super.init(frame: .zero)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension SOSView {
    func setup(pin: String) {
        let result = NSMutableAttributedString()
        result.append("SOS.PIN.Title".localized.attributed(with: pinTitleAttrs))
        result.append(pin.attributed(with: pinAttrs))
        
        pinLabel.attributedText = result
    }
    
    func setup(action: SOSActiveButton.Action) {
        switch action {
        case .touchDown:
            update(size: 300.scale)
            update(text: "SOS.Action.Release".localized)
        case .touchUpInside, .touchUpOutside:
            update(size: 256.scale)
            update(text: "SOS.Action.PressAndHold".localized)
        }
        
        circleLabel.isHidden = action == .touchDown
        photosContainer.isHidden = action == .touchDown
        pinLabel.isHidden = action != .touchDown
    }
}

// MARK: Private
private extension SOSView {
    func initialize() {
        backgroundColor = Appearance.background1
        
        circle.members.forEach { member in
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.layer.masksToBounds = true
            imageView.layer.cornerRadius = 20.scale
            imageView.layer.borderWidth = 1.scale
            imageView.layer.borderColor = Appearance.background1.cgColor
            imageView.translatesAutoresizingMaskIntoConstraints = false
            photosContainer.addArrangedSubview(imageView)
            
            imageView.backgroundColor = member.photo == nil ? Appearance.primary2 : UIColor.clear
            
            if let photoUrl = member.photo?.url {
                imageView.kf.setImage(with: photoUrl)
            }
            
            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: 48.scale),
                imageView.heightAnchor.constraint(equalToConstant: 49.scale)
            ])
        }
    }
    
    func update(size: CGFloat) {
        NSLayoutConstraint.deactivate([
            sosWidthConstraint,
            sosHeightConstraint
        ])
        
        sosWidthConstraint.constant = size
        sosHeightConstraint.constant = size
        
        NSLayoutConstraint.activate([
            sosWidthConstraint,
            sosHeightConstraint
        ])
        
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.sosButton.layoutIfNeeded()
        })
    }
    
    func update(text: String) {
        actionLabel.attributedText = text.attributed(with: actionAttrs)
    }
}

// MARK: Make constraints
private extension SOSView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            closeButton.widthAnchor.constraint(equalToConstant: 24.scale),
            closeButton.heightAnchor.constraint(equalToConstant: 24.scale),
            closeButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            closeButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            instructionButton.widthAnchor.constraint(equalToConstant: 24.scale),
            instructionButton.heightAnchor.constraint(equalToConstant: 24.scale),
            instructionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            instructionButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            actionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40.scale),
            actionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40.scale),
            actionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: ScreenSize.isIphoneXFamily ? 75.scale : 45.scale)
        ])
        
        sosWidthConstraint = sosButton.widthAnchor.constraint(equalToConstant: 256.scale)
        sosHeightConstraint = sosButton.heightAnchor.constraint(equalToConstant: 256.scale)
        NSLayoutConstraint.activate([
            sosWidthConstraint,
            sosHeightConstraint,
            sosButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            sosButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            circleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            circleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            circleLabel.bottomAnchor.constraint(equalTo: photosContainer.topAnchor, constant: -16.scale)
        ])
        
        NSLayoutConstraint.activate([
            photosContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24.scale),
            photosContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24.scale),
            photosContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: ScreenSize.isIphoneXFamily ? -60.scale : -30.scale),
            photosContainer.heightAnchor.constraint(equalToConstant: 48.scale)
        ])
        
        NSLayoutConstraint.activate([
            pinLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            pinLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: ScreenSize.isIphoneXFamily ? -60.scale : -30.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension SOSView {
    func makeCloseButton() -> TapAreaButton {
        let view = TapAreaButton()
        view.setImage(UIImage(named: "SOS.Close"), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.black2)
            .font(Fonts.RobotoCondensed.medium(size: 18.scale))
            .lineHeight(25.2.scale)
            .textAlignment(.center)
        
        let view = UILabel()
        view.attributedText = "SOS.Title".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeInstructionButton() -> TapAreaButton {
        let view = TapAreaButton()
        view.setImage(UIImage(named: "SOS.Instruction"), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeActionLabel() -> PaddingLabel {
        let view = PaddingLabel()
        view.attributedText = "SOS.Action.PressAndHold".localized.attributed(with: actionAttrs)
        view.insets = UIEdgeInsets(vertical: 8.scale)
        view.backgroundColor = Appearance.background2
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeSOSButton() -> SOSActiveButton {
        let view = SOSActiveButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeCircleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.black1)
            .font(Fonts.RobotoCondensed.regular(size: 16.scale))
            .lineHeight(22.4.scale)
            .textAlignment(.center)
        
        let string = String(format: "SOS.CircleMembers".localized, circle.name)
        
        let view = UILabel()
        view.attributedText = string.attributed(with: attrs)
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makePhotosContainer() -> UIStackView {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = -40.scale
        view.alignment = .center
        view.distribution = .fillEqually
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makePINLabel() -> UILabel {
        let view = UILabel()
        view.isHidden = true
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
