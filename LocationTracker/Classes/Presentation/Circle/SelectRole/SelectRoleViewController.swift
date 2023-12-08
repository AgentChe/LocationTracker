//
//  SelectRoleViewController.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 07.12.2023.
//

import UIKit
import RxSwift

final class SelectRoleViewController: UIViewController {
    lazy var mainView = SelectRoleView()
    
    private let viewModel: SelectRoleViewModel
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var closeButton = UIButton()
    
    private init(data: CreateCircleCombineData) {
        viewModel = SelectRoleViewModel(data: data)
        
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
    static func make(data: CreateCircleCombineData) -> SelectRoleViewController {
        let vc = SelectRoleViewController(data: data)
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
        }
    }
}
