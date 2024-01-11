//
//  SavedPlacesTableCell.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 11.01.2024.
//

import UIKit

final class SavedPlacesTableCell: UITableViewCell {
    lazy var container = makeContainer()
    lazy var markerView = makeMarkerView()
    lazy var label = makeLabel()
    lazy var arrowView = makeArrowView()
    
    private lazy var attrs = TextAttributes()
        .textColor(Appearance.black2.withAlphaComponent(0.6))
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
extension SavedPlacesTableCell {
    func setup(element: GeocodeResult) {
        label.attributedText = element.address?.attributed(with: attrs)
    }
}

// MARK: Private
private extension SavedPlacesTableCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension SavedPlacesTableCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16.scale),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            markerView.widthAnchor.constraint(equalToConstant: 32.scale),
            markerView.heightAnchor.constraint(equalToConstant: 32.scale),
            markerView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            markerView.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 60.scale),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -52.scale),
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 16.scale),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16.scale)
        ])
        
        NSLayoutConstraint.activate([
            arrowView.widthAnchor.constraint(equalToConstant: 24.scale),
            arrowView.heightAnchor.constraint(equalToConstant: 24.scale),
            arrowView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            arrowView.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension SavedPlacesTableCell {
    func makeContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.white
        view.layer.cornerRadius = 10.scale
        view.layer.borderWidth = 1.scale
        view.layer.borderColor = Appearance.background2.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeMarkerView() -> UIImageView {
        let view = UIImageView()
        view.clipsToBounds = true
        view.image = UIImage(named: "SavedPlaces.Marker")
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeArrowView() -> UIImageView {
        let view = UIImageView()
        view.clipsToBounds = true
        view.image = UIImage(named: "SavedPlaces.Arrow.Right")
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
}
