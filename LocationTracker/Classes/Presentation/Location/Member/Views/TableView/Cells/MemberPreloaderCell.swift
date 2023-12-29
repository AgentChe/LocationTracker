//
//  MemberPreloaderCell.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 29.12.2023.
//

import UIKit

final class MemberPreloaderCell: UITableViewCell {
    lazy var preloader = makePreloader()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension MemberPreloaderCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension MemberPreloaderCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            preloader.widthAnchor.constraint(equalToConstant: 45.scale),
            preloader.heightAnchor.constraint(equalToConstant: 45.scale),
            preloader.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            preloader.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension MemberPreloaderCell {
    func makePreloader() -> UIActivityIndicatorView {
        let view = UIActivityIndicatorView()
        view.hidesWhenStopped = true
        view.style = .large
        view.color = Appearance.primary1
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
}
