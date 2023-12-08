//
//  CreateCircleCodeView.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 07.12.2023.
//

import UIKit

final class CreateCircleCodeView: UIView {
    lazy var doneButton = makeDoneButton()
    lazy var titleLabel = makeTitleLabel()
    lazy var codeLabel = makeCodeLabel()
    lazy var subTitleLabel = makeSubTitleLabel()
    lazy var inviteButton = makeInviteButton()
    lazy var worksTitleLabel = makeWorksTitleLabel()
    lazy var cell1 = makeCell(
        iconName: "CreateCircleCode.Cell1",
        text: "CreateCircleCode.Works.Cell1".localized
    )
    lazy var cell2 = makeCell(
        iconName: "CreateCircleCode.Cell2",
        text: "CreateCircleCode.Works.Cell2".localized
    )
    lazy var preloader = makePreloader()
    
    private lazy var codeAttrs = TextAttributes()
        .textColor(Appearance.secondary)
        .font(Fonts.RobotoCondensed.medium(size: 48.scale))
        .lineHeight(67.2.scale)
        .textAlignment(.center)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension CreateCircleCodeView {
    func setup(code: String) {
        codeLabel.attributedText = code.attributed(with: codeAttrs)
    }
}

// MARK: Private
private extension CreateCircleCodeView {
    func initialize() {
        backgroundColor = Appearance.background1
    }
}

// MARK: Make constraints
private extension CreateCircleCodeView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            doneButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            doneButton.topAnchor.constraint(equalTo: topAnchor, constant: 16.scale)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 87.scale)
        ])
        
        NSLayoutConstraint.activate([
            codeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32.scale),
            codeLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            subTitleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            subTitleLabel.topAnchor.constraint(equalTo: codeLabel.bottomAnchor, constant: 8.scale)
        ])
        
        NSLayoutConstraint.activate([
            inviteButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            inviteButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            inviteButton.heightAnchor.constraint(equalToConstant: 56.scale),
            inviteButton.topAnchor.constraint(equalTo: subTitleLabel.bottomAnchor, constant: 32.scale)
        ])
        
        NSLayoutConstraint.activate([
            worksTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            worksTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            worksTitleLabel.topAnchor.constraint(equalTo: inviteButton.bottomAnchor, constant: 40.scale)
        ])
        
        NSLayoutConstraint.activate([
            cell1.leadingAnchor.constraint(equalTo: leadingAnchor),
            cell1.trailingAnchor.constraint(equalTo: trailingAnchor),
            cell1.topAnchor.constraint(equalTo: worksTitleLabel.bottomAnchor, constant: 18.scale)
        ])
        
        NSLayoutConstraint.activate([
            cell2.leadingAnchor.constraint(equalTo: leadingAnchor),
            cell2.trailingAnchor.constraint(equalTo: trailingAnchor),
            cell2.topAnchor.constraint(equalTo: cell1.bottomAnchor, constant: 20.scale)
        ])
        
        NSLayoutConstraint.activate([
            preloader.centerXAnchor.constraint(equalTo: centerXAnchor),
            preloader.centerYAnchor.constraint(equalTo: centerYAnchor),
            preloader.widthAnchor.constraint(equalToConstant: 45.scale),
            preloader.heightAnchor.constraint(equalToConstant: 45.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension CreateCircleCodeView {
    func makeDoneButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.primary1)
            .font(Fonts.RobotoCondensed.medium(size: 18.scale))
        
        let view = UIButton()
        view.setAttributedTitle("CreateCircleCode.Done".localized.attributed(with: attrs), for: .normal)
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.black2)
            .font(Fonts.RobotoCondensed.medium(size: 24.scale))
            .lineHeight(33.6.scale)
            .textAlignment(.center)
        
        let view = UILabel()
        view.attributedText = "CreateCircleCode.Title".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeCodeLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeSubTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.black1)
            .font(Fonts.RobotoCondensed.regular(size: 16.scale))
            .lineHeight(22.4.scale)
            .textAlignment(.center)
        
        let view = UILabel()
        view.attributedText = "CreateCircleCode.SubTitle".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeInviteButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.white)
            .font(Fonts.RobotoCondensed.semiBold(size: 16.scale))
        
        let view = UIButton()
        view.setAttributedTitle("CreateCircleCode.InviteButton".localized.attributed(with: attrs), for: .normal)
        view.layer.cornerRadius = 20.scale
        view.backgroundColor = Appearance.primary1
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeWorksTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.black2)
            .font(Fonts.RobotoCondensed.medium(size: 18.scale))
            .lineHeight(25.2.scale)
            .textAlignment(.left)
        
        let view = UILabel()
        view.attributedText = "CreateCircleCode.Works.Title".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeCell(iconName: String, text: String) -> InviteWorksCell {
        let view = InviteWorksCell(iconName: iconName, text: text)
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makePreloader() -> UIActivityIndicatorView {
        let view = UIActivityIndicatorView()
        view.hidesWhenStopped = true
        view.style = .large
        view.color = Appearance.primary1
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
