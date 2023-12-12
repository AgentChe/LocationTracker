//
//  CirclesViewController.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 06.12.2023.
//

import UIKit
import RxSwift

final class CirclesViewController: UIViewController {
    lazy var mainView = CirclesView()
    
    private lazy var viewModel = CirclesViewModel()
    
    private lazy var disposeBag = DisposeBag()
    
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
        
        let output = viewModel.configure(input: CirclesViewModel.Input(
            didTapCreate: mainView.createButton.rx.tap.asSignal(),
            didTapJoin: mainView.joinButton.rx.tap.asSignal(),
            didTapClose: mainView.closeButton.rx.tap.asSignal(),
            didSelectElement: mainView.tableView.didSelect
        ))
        
        output.activity
            .drive(Binder(mainView) { base, activity in
                base.tableView.isHidden = activity
                activity ? base.preloader.startAnimating() : base.preloader.stopAnimating()
            })
            .disposed(by: disposeBag)
        
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
extension CirclesViewController {
    static func make() -> CirclesViewController {
        CirclesViewController()
    }
}

// MARK: Private
private extension CirclesViewController {
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
    
    func route(_ route: CirclesViewModel.Route) {
        switch route {
        case .create:
            let nc = NavigationController(rootViewController: CreateCircleViewController.make())
            present(nc, animated: true)
        case .join:
            let nc = NavigationController(rootViewController: JoinToCircleViewController.make())
            present(nc, animated: true)
        case .dismiss:
            dismiss(animated: true)
        case .details(let circle):
            let vc = DetailsCircleViewController.make(circle: circle)
            present(vc, animated: true)
        }
    }
}
