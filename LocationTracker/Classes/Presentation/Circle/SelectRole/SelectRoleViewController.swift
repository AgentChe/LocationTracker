//
//  SelectRoleViewController.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 07.12.2023.
//

import UIKit
import RxSwift

final class SelectRoleViewController: UIViewController {
    enum Mode {
        case flow(CreateCircleCombineData)
        case select(Role?)
    }
    
    lazy var mainView = SelectRoleView()
    
    private let viewModel: SelectRoleViewModel
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var closeButton = UIButton()
    
    private let selected: ((Role) -> Void)?
    
    private init(mode: SelectRoleViewController.Mode, selected: ((Role) -> Void)?) {
        self.viewModel = SelectRoleViewModel(mode: mode)
        self.selected = selected
        
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
        
        let output = viewModel.configure(input: SelectRoleViewModel.Input(
            didTapClose: closeButton.rx.tap.asSignal(),
            didSelect: mainView.tableView.didSelect,
            didTapContinue: mainView.continueButton.rx.tap.asSignal()
        ))
        
        output.elements
            .drive(Binder(mainView.tableView) { base, elements in
                base.setup(elements: elements)
            })
            .disposed(by: disposeBag)
        
        output.isContinueEnable
            .drive(Binder(mainView.continueButton) { base, enable in
                base.isEnabled = enable
                base.alpha = enable ? 1 : 0.4
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
extension SelectRoleViewController {
    static func make(mode: SelectRoleViewController.Mode, selected: ((Role) -> Void)? = nil) -> SelectRoleViewController {
        let vc = SelectRoleViewController(mode: mode, selected: selected)
        vc.navigationItem.backButtonTitle = " "
        vc.navigationItem.title = "SelectRole.Title".localized
        return vc
    }
}

// MARK: Private
private extension SelectRoleViewController {
    func addCloseButton() {
        closeButton.setImage(UIImage(named: "CreateCircle.Close"), for: .normal)
        
        let item = UIBarButtonItem(customView: closeButton)
        item.customView?.translatesAutoresizingMaskIntoConstraints = false
        
        item.customView?.widthAnchor.constraint(equalToConstant: 24.scale).isActive = true
        item.customView?.heightAnchor.constraint(equalToConstant: 24.scale).isActive = true
        
        navigationItem.rightBarButtonItem = item
    }
    
    func route(_ route: SelectRoleViewModel.Route) {
        switch route {
        case .dismiss:
            navigationController?.dismiss(animated: true)
        case .createCode(let data):
            let vc = CreateCircleCodeViewController.make(data: data)
            navigationController?.pushViewController(vc, animated: true)
        case .complete(let role):
            navigationController?.dismiss(animated: true) { [weak self] in
                self?.selected?(role)
            }
        }
    }
}
