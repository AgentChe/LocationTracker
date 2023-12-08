//
//  RolesTableCell.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 07.12.2023.
//

import UIKit

final class RolesTableCell: UITableViewCell {
    lazy var container = makeContainer()
    lazy var label = makeLabel()
    
    private lazy var selectedAttrs = TextAttributes()
        .textColor(Appearance.white)
        .font(Fonts.RobotoCondensed.regular(size: 16.scale))
        .lineHeight(22.4.scale)
        .textAlignment(.center)
    private lazy var normalAttrs = TextAttributes()
            .textColor(Appearance.black2)
            .font(Fonts.RobotoCondensed.regular(size: 16.scale))
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
extension RolesTableCell {
    func setup(element: RolesTableElement) {
        container.backgroundColor = element.marked ? Appearance.primary1 : Appearance.white
        container.layer.borderWidth = element.marked ? 0 : 1.scale
        container.layer.borderColor = element.marked ? UIColor.clear.cgColor : Appearance.background2.cgColor
        
        let attrs = element.marked ? selectedAttrs : normalAttrs
        label.attributedText = element.role.name.attributed(with: attrs)
    }
}

// MARK: Private
private extension RolesTableCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension RolesTableCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8.scale),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8.scale)
        ])
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 20.scale),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -20.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension RolesTableCell {
    func makeContainer() -> UIView {
        let view = UIView()
        view.layer.cornerRadius = 10.scale
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
}
