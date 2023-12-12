//
//  EditCircleViewController.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 12.12.2023.
//

import UIKit
import RxSwift
import RxCocoa

final class EditCircleViewController: UIViewController {
    lazy var mainView = EditCircleView()
    
    private let viewModel: EditCircleViewModel
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var closeButton = UIButton()
    
    private lazy var updatedInfoTrigger = PublishRelay<EditCircleViewModel.Info>()
    private lazy var updatedRoleTrigger = PublishRelay<Role>()
    
    private init(circle: Circle) {
        viewModel = EditCircleViewModel(circle: circle)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let output = viewModel.configure(input: EditCircleViewModel.Input(
            didTapClose: closeButton.rx.tap.asSignal(),
            didEditName: mainView.tableView.didEditName,
            didEditRole: mainView.tableView.didEditRole,
            didDeleteMember: mainView.tableView.didDeleteMember,
            didAddMember: mainView.tableView.didAddMember,
            didSave: mainView.saveButton.rx.tap.asSignal(),
            updatedInfo: updatedInfoTrigger.asSignal(),
            updatedRole: updatedRoleTrigger.asSignal()
        ))
        
        output.elements
            .drive(Binder(mainView.tableView) { base, elements in
                base.setup(elements: elements)
            })
            .disposed(by: disposeBag)
        
        output.route
            .drive(Binder(self) { base, route in
                base.route(route)
            })
            .disposed(by: disposeBag)
        
        addCloseButton()
    }
}

// MARK: Public
extension EditCircleViewController {
    static func make(circle: Circle) -> EditCircleViewController {
        let vc = EditCircleViewController(circle: circle)
        vc.navigationItem.backButtonTitle = " "
        vc.navigationItem.title = "EditCircle.Title".localized
        return vc
    }
}

// MARK: Private
private extension EditCircleViewController {
    func addCloseButton() {
        closeButton.setImage(UIImage(named: "CreateCircle.Close"), for: .normal)
        
        let item = UIBarButtonItem(customView: closeButton)
        item.customView?.translatesAutoresizingMaskIntoConstraints = false
        
        item.customView?.widthAnchor.constraint(equalToConstant: 24.scale).isActive = true
        item.customView?.heightAnchor.constraint(equalToConstant: 24.scale).isActive = true
        
        navigationItem.rightBarButtonItem = item
    }
    
    func route(_ route: EditCircleViewModel.Route) {
        switch route {
        case .dismiss:
            navigationController?.dismiss(animated: true)
        case .editInfo(let info):
            break
        case .editRole(let role):
            let vc = SelectRoleViewController.make(mode: .select(role)) { [weak self] selected in
                self?.updatedRoleTrigger.accept(selected)
            }
            let nc = NavigationController(rootViewController: vc)
            present(nc, animated: true)
        case .addMember(let inviteCode):
            let vc = InviteViewController.make(inviteCode: inviteCode)
            present(vc, animated: true)
        }
    }
}
