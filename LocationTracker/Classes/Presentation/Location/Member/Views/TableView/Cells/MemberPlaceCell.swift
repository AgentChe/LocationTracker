//
//  MemberPlaceCell.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 28.12.2023.
//

import UIKit

final class MemberPlaceCell: UITableViewCell {
    var didAddPlace: (() -> Void)?
    var didRefresh: (() -> Void)?
    
    lazy var container = makeContainer()
    lazy var contentLabel = makeLabel()
    lazy var refreshButton = makeRefreshButton()
    lazy var addPlaceButton = makeAddButton()
    
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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension MemberPlaceCell {
    func setup(element: MemberPlaceElement) {
        let address = element.address.attributed(with: addressAttrs)
        let result = NSMutableAttributedString(attributedString: address)
        
        if let updated = element.updated {
            result.append("\n".attributed(with: updatedAttrs))
            result.append(updated.attributed(with: updatedAttrs))
        }
        
        contentLabel.attributedText = result
        
        refreshButton.isHidden = !element.withRefresh
    }
}

// MARK: Private
private extension MemberPlaceCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
    
    @objc
    func didTapAddPlace() {
        didAddPlace?()
    }
    
    @objc
    func didTapRefresh() {
        didRefresh?()
    }
}

// MARK: Make constraints
private extension MemberPlaceCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16.scale),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            contentLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            contentLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -48.scale),
            contentLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 16.scale),
            contentLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -68.scale)
        ])
        
        NSLayoutConstraint.activate([
            refreshButton.widthAnchor.constraint(equalToConstant: 24.scale),
            refreshButton.heightAnchor.constraint(equalToConstant: 24.scale),
            refreshButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            refreshButton.centerYAnchor.constraint(equalTo: contentLabel.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            addPlaceButton.widthAnchor.constraint(equalToConstant: 121.scale),
            addPlaceButton.heightAnchor.constraint(equalToConstant: 38.scale),
            addPlaceButton.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            addPlaceButton.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 12.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension MemberPlaceCell {
    func makeContainer() -> UIView {
        let view = UIView()
        view.layer.cornerRadius = 10.scale
        view.layer.borderWidth = 1.scale
        view.layer.borderColor = Appearance.background2.cgColor
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
    
    func makeRefreshButton() -> TapAreaButton {
        let view = TapAreaButton()
        view.setImage(UIImage(named: "Member.Refresh"), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(didTapRefresh), for: .touchUpInside)
        container.addSubview(view)
        return view
    }
    
    func makeAddButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.white)
            .font(Fonts.RobotoCondensed.medium(size: 16.scale))
        
        let view = UIButton()
        view.setAttributedTitle("Member.AddPlace".localized.attributed(with: attrs), for: .normal)
        view.layer.cornerRadius = 10.scale
        view.backgroundColor = Appearance.primary1
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(didTapAddPlace), for: .touchUpInside)
        container.addSubview(view)
        return view
    }
}
