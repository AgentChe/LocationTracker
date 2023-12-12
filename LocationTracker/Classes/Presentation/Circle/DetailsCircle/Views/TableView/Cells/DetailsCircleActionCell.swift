//
//  DetailsCircleActionCell.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 11.12.2023.
//

import UIKit

final class DetailsCircleActionCell: UITableViewCell {
    lazy var label = makeLabel()
    
    private lazy var whiteAttrs = TextAttributes()
        .textColor(Appearance.white)
        .font(Fonts.RobotoCondensed.medium(size: 16.scale))
        .lineHeight(22.4.scale)
        .textAlignment(.center)
    private lazy var primaryAttrs = TextAttributes()
        .textColor(Appearance.primary1)
        .font(Fonts.RobotoCondensed.medium(size: 16.scale))
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
}

// MARK: Public
extension DetailsCircleActionCell {
    func setup(action: DetailsCircleTableAction) {
        switch action {
        case .edit:
            label.attributedText = "DetailsCircle.Edit".localized.attributed(with: whiteAttrs)
            label.backgroundColor = Appearance.primary1
        case .delete:
            label.attributedText = "DetailsCircle.Delete".localized.attributed(with: primaryAttrs)
            label.backgroundColor = Appearance.primary2
        case .addMember:
            label.attributedText = "DetailsCircle.AddMember".localized.attributed(with: primaryAttrs)
            label.backgroundColor = Appearance.primary2
        }
    }
}

// MARK: Private
private extension DetailsCircleActionCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension DetailsCircleActionCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16.scale),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension DetailsCircleActionCell {
    func makeLabel() -> PaddingLabel {
        let view = PaddingLabel()
        view.insets = UIEdgeInsets(vertical: 16.scale)
        view.layer.cornerRadius = 20.scale
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
}
