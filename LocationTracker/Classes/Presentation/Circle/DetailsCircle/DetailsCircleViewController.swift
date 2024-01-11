//
//  DetailsCircleViewController.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 11.12.2023.
//

import UIKit
import RxSwift
import RxCocoa

final class DetailsCircleViewController: UIViewController {
    lazy var mainView = DetailsCircleView()
    
    private let viewModel: DetailsCircleViewModel
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var didDeleteTrigger = PublishRelay<Void>()
    
    private init(circle: Circle) {
        viewModel = DetailsCircleViewModel(circle: circle)
        
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
        
        viewModel.tryAgain = { [weak self] error -> Observable<Void> in
            guard let self = self else {
                return .never()
            }

            return self.open(error: error)
        }
        
        let output = viewModel.configure(input: DetailsCircleViewModel.Input(
            didTapClose: mainView.headerView.rx.tap.asSignal(),
            didSelect: mainView.tableView.didSelect,
            didDelete: didDeleteTrigger.asSignal()
        ))
        
        output.name
            .drive(Binder(mainView.headerView) { base, name in
                base.setup(name: name)
            })
            .disposed(by: disposeBag)
        
        output.elements
            .drive(Binder(mainView.tableView) { base, elements in
                base.setup(elements: elements)
            })
            .disposed(by: disposeBag)
        
        output.activity
            .drive(Binder(mainView.preloader) { base, activity in
                activity ? base.startAnimating() : base.stopAnimating()
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
extension DetailsCircleViewController {
    static func make(circle: Circle) -> DetailsCircleViewController {
        DetailsCircleViewController(circle: circle)
    }
}

// MARK: Privates
private extension DetailsCircleViewController {
    func open(error: Error) -> Observable<Void> {
        Observable<Void>
            .create { [weak self] observe in
                guard let self = self else {
                    return Disposables.create()
                }
                
                let vc = TryAgainViewController.make(error: error) {
                    observe.onNext(())
                }
                self.present(vc, animated: true)
                
                return Disposables.create()
            }
    }
    
    func route(_ route: DetailsCircleViewModel.Route) {
        switch route {
        case .dismiss:
            dismiss(animated: true)
        case .edit(let circle):
            let nc = NavigationController(rootViewController: EditCircleViewController.make(circle: circle))
            present(nc, animated: true)
        case .delete:
            let model = ConfirmDeleteViewController.Model(
                title: "DetailsCircle.ConfirmDelete.Title".localized,
                text: "DetailsCircle.ConfirmDelete.SubTitle".localized,
                confirmText: "DetailsCircle.ConfirmDelete.DeleteButton".localized,
                cancelText: "Cancel".localized
            )
            let vc = ConfirmDeleteViewController.make(model: model) { [weak self] in
                self?.didDeleteTrigger.accept(Void())
            }
            present(vc, animated: false)
        case .addMember(let inviteCode):
            let vc = InviteViewController.make(inviteCode: inviteCode)
            present(vc, animated: true)
        }
    }
}
