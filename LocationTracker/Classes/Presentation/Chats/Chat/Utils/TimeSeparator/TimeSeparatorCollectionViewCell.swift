//
//  TimeSeparatorCollectionViewCell.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 08.02.2024.
//

import UIKit

final class TimeSeparatorCollectionViewCell: UICollectionViewCell {
    lazy var label = makeLabel()
    
    private lazy var attrs = TextAttributes()
        .textColor(Appearance.black2.withAlphaComponent(0.6))
        .font(Fonts.RobotoCondensed.regular(size: 16.scale))
        .lineHeight(22.4.scale)

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
extension TimeSeparatorCollectionViewCell {
    func setup(time: String) {
        label.attributedText = time.attributed(with: attrs)
    }
}

// MARK: Private
private extension TimeSeparatorCollectionViewCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
    }
}

// MARK: Make constraints
private extension TimeSeparatorCollectionViewCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension TimeSeparatorCollectionViewCell {
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
}
