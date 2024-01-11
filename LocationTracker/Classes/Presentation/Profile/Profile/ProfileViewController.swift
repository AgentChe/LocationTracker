//
//  ProfileViewController.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 21.12.2023.
//

import UIKit
import RxSwift

final class ProfileViewController: UIViewController {
    lazy var mainView = ProfileView()
    
    private lazy var viewModel = ProfileViewModel()
    
    private lazy var disposeBag = DisposeBag()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let output = viewModel.configure(input: ProfileViewModel.Input(
            didTapEdit: mainView.tableView.didEdit,
            didTapMenu: mainView.tableView.didMenuTap
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
    }
}

// MARK: Public
extension ProfileViewController {
    static func make() -> ProfileViewController {
        let vc = ProfileViewController()
        vc.navigationItem.backButtonTitle = " "
        return vc
    }
}

// MARK: Private
private extension ProfileViewController {
    func route(_ route: ProfileViewModel.Route) {
        switch route {
        case .edit:
            let nc = NavigationController(rootViewController: EditProfileViewController.make())
            present(nc, animated: true)
        case .savePlaces:
            let nc = NavigationController(rootViewController: SavedPlacesViewController.make())
            present(nc, animated: true)
        case .changePIN:
            break // TODO
        case .settings:
            let vc = SettingsViewController.make()
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
