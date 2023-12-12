//
//  EditCircleTableView.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 12.12.2023.
//

import UIKit
import RxSwift
import RxCocoa

final class EditCircleTableView: UITableView {
    lazy var elements = [EditCircleTableElement]()
    
    private lazy var didEditNameTrigger = PublishRelay<Void>()
    private lazy var didEditRoleTrigger = PublishRelay<Void>()
    private lazy var didDeleteMemberTrigger = PublishRelay<Member>()
    private lazy var didAddMemberTrigger = PublishRelay<Void>()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension EditCircleTableView {
    func setup(elements: [EditCircleTableElement]) {
        self.elements = elements
        
        reloadData()
    }
    
    var didEditName: Signal<Void> {
        didEditNameTrigger.asSignal()
    }
    
    var didEditRole: Signal<Void> {
        didEditRoleTrigger.asSignal()
    }
    
    var didDeleteMember: Signal<Member> {
        didDeleteMemberTrigger.asSignal()
    }
    
    var didAddMember: Signal<Void> {
        didAddMemberTrigger.asSignal()
    }
}

// MARK: UITableViewDataSource
extension EditCircleTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch elements[indexPath.row] {
        case .name(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: EditCircleNameCell.self)) as! EditCircleNameCell
            cell.setup(element: element)
            cell.didTapEdit = { [weak self] in
                self?.didEditNameTrigger.accept(Void())
            }
            return cell
        case .role(let role):
            let cell = dequeueReusableCell(withIdentifier: String(describing: EditCircleRoleCell.self)) as! EditCircleRoleCell
            cell.setup(role: role)
            cell.didTapEdit = { [weak self] in
                self?.didEditRoleTrigger.accept(Void())
            }
            return cell
        case .membersTitle:
            return dequeueReusableCell(withIdentifier: String(describing: DetailsCircleTitleCell.self), for: indexPath)
        case .member(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: EditCircleMemberCell.self)) as! EditCircleMemberCell
            cell.setup(element: element)
            cell.didTapDelete = { [weak self] in
                self?.didDeleteMemberTrigger.accept(element.member)
            }
            return cell
        case .addMember:
            return dequeueReusableCell(withIdentifier: String(describing: EditCircleAddMemberCell.self), for: indexPath)
        }
    }
}

// MARK: UITableViewDelegate
extension EditCircleTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard case .addMember = elements[indexPath.row] else {
            return
        }
        
        didAddMemberTrigger.accept(Void())
    }
}

// MARK: Private
private extension EditCircleTableView {
    func initialize() {
        register(EditCircleNameCell.self, forCellReuseIdentifier: String(describing: EditCircleNameCell.self))
        register(EditCircleRoleCell.self, forCellReuseIdentifier: String(describing: EditCircleRoleCell.self))
        register(EditCircleMemberCell.self, forCellReuseIdentifier: String(describing: EditCircleMemberCell.self))
        register(EditCircleAddMemberCell.self, forCellReuseIdentifier: String(describing: EditCircleAddMemberCell.self))
        register(DetailsCircleTitleCell.self, forCellReuseIdentifier: String(describing: DetailsCircleTitleCell.self))
        
        dataSource = self
        delegate = self 
    }
}
