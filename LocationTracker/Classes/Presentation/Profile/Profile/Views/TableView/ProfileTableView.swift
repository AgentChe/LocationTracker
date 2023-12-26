//
//  ProfileTableView.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 26.12.2023.
//

import UIKit
import RxSwift
import RxCocoa

final class ProfileTableView: UITableView {
    lazy var elements = [ProfileTableElement]()
    
    private lazy var didEditTrigger = PublishRelay<Void>()
    private lazy var didMenuTapTrigger = PublishRelay<ProfileMenuButton.MenuItem>()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension ProfileTableView {
    func setup(elements: [ProfileTableElement]) {
        self.elements = elements
        
        reloadData()
    }
    
    var didEdit: Signal<Void> {
        didEditTrigger.asSignal()
    }
    
    var didMenuTap: Signal<ProfileMenuButton.MenuItem> {
        didMenuTapTrigger.asSignal()
    }
}

// MARK: UITableViewDataSource
extension ProfileTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch elements[indexPath.row] {
        case .title:
            return dequeueReusableCell(withIdentifier: String(describing: ProfileTitleCell.self), for: indexPath)
        case .edit(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: ProfileEditCell.self), for: indexPath) as! ProfileEditCell
            cell.setup(element: element)
            cell.didEdit = { [weak self] in
                self?.didEditTrigger.accept(Void())
            }
            return cell
        case .menu:
            let cell = dequeueReusableCell(withIdentifier: String(describing: ProfileMenuCell.self), for: indexPath) as! ProfileMenuCell
            cell.didTap = { [weak self] item in
                self?.didMenuTapTrigger.accept(item)
            }
            return cell
        }
    }
}

// MARK: UITableViewDelegate
extension ProfileTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}

// MARK: Private
private extension ProfileTableView {
    func initialize() {
        register(ProfileTitleCell.self, forCellReuseIdentifier: String(describing: ProfileTitleCell.self))
        register(ProfileEditCell.self, forCellReuseIdentifier: String(describing: ProfileEditCell.self))
        register(ProfileMenuCell.self, forCellReuseIdentifier: String(describing: ProfileMenuCell.self))
        
        dataSource = self
        delegate = self
    }
}
