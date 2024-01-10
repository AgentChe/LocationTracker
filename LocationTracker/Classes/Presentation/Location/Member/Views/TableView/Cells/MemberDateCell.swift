//
//  MemberDateCell.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 10.01.2024.
//

import UIKit

final class MemberDateCell: UITableViewCell {
    var didTapBack: ((Date) -> Void)?
    var didTapNext: ((Date) -> Void)?
    
    lazy var container = makeContainer()
    lazy var backButton = makeBackButton()
    lazy var label = makeLabel()
    lazy var nextButton = makeNextButton()
    
    private lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM, dd"
        formatter.locale = Locale(identifier: "en_EN")
        return formatter
    }()
    
    private lazy var attrs = TextAttributes()
        .textColor(Appearance.primary1)
        .font(Fonts.RobotoCondensed.medium(size: 18.scale))
        .lineHeight(25.2.scale)
        .textAlignment(.center)
    
    private var currentDate: Date?
    
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
extension MemberDateCell {
    func setup(element: Date) {
        currentDate = element
        
        let isCurrentDay = Calendar.current.isDateInToday(element)
        nextButton.isHidden = isCurrentDay
        
        let date = formatter.string(from: element)
        label.attributedText = date.attributed(with: attrs)
    }
}

// MARK: Private
private extension MemberDateCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
    
    @objc
    func didTapBackButton() {
        guard let currentDate else {
            return
        }
        
        didTapBack?(currentDate)
    }
    
    @objc
    func didTapNextButton() {
        guard let currentDate else {
            return
        }
        
        didTapNext?(currentDate)
    }
}

// MARK: Make constraints
private extension MemberDateCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            container.heightAnchor.constraint(equalToConstant: 41.scale),
            container.widthAnchor.constraint(equalToConstant: 190.scale)
        ])
        
        NSLayoutConstraint.activate([
            backButton.widthAnchor.constraint(equalToConstant: 24.scale),
            backButton.heightAnchor.constraint(equalToConstant: 24.scale),
            backButton.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12.scale),
            backButton.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            nextButton.widthAnchor.constraint(equalToConstant: 24.scale),
            nextButton.heightAnchor.constraint(equalToConstant: 24.scale),
            nextButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12.scale),
            nextButton.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension MemberDateCell {
    func makeContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.white
        view.layer.cornerRadius = 20.scale
        view.layer.borderWidth = 1.scale
        view.layer.borderColor = Appearance.background2.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeBackButton() -> TapAreaButton {
        let view = TapAreaButton()
        view.setImage(UIImage(named: "Member.Back"), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        container.addSubview(view)
        return view
    }
    
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeNextButton() -> TapAreaButton {
        let view = TapAreaButton()
        view.setImage(UIImage(named: "Member.Next"), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
        container.addSubview(view)
        return view
    }
}
