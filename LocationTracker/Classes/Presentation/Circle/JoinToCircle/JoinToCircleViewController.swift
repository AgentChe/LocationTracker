//
//  JoinToCircleViewController.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 08.12.2023.
//

import UIKit
import RxSwift

final class JoinToCircleViewController: UIViewController {
    lazy var mainView = JoinToCircleView()
    
    private lazy var viewModel = JoinToCircleViewModel()
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var closeButton = UIButton()
    
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
        
        let didTapSubmit = mainView.submitButton.rx.tap
            .compactMap { [weak self] void -> String? in
                self?.mainView.codesFields
                    .map { $0.text ?? "" }
                    .joined()
            }
            .asSignal(onErrorSignalWith: .never())
        
        let output = viewModel.configure(input: JoinToCircleViewModel.Input(
            didTapClose: closeButton.rx.tap.asSignal(),
            didTapSubmit: didTapSubmit
        ))
        
        output.route
            .drive(Binder(self) { base, route in
                base.route(route)
            })
            .disposed(by: disposeBag)
        
        output.activity
            .drive(Binder(mainView) { base, activity in
                base.submitButton.isHidden = activity
                activity ? base.preloader.startAnimating() : base.preloader.stopAnimating()
            })
            .disposed(by: disposeBag)
        
        addCloseButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        mainView.code1Field.becomeFirstResponder()
    }
}

// MARK: Public
extension JoinToCircleViewController {
    static func make() -> JoinToCircleViewController {
        let vc = JoinToCircleViewController()
        vc.navigationItem.title = "JoinToCircle.Title".localized
        vc.navigationItem.backButtonTitle = " "
        return vc
    }
}

// MARK: Private
private extension JoinToCircleViewController {
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
    
    func addCloseButton() {
        closeButton.setImage(UIImage(named: "CreateCircle.Close"), for: .normal)
        
        let item = UIBarButtonItem(customView: closeButton)
        item.customView?.translatesAutoresizingMaskIntoConstraints = false
        
        item.customView?.widthAnchor.constraint(equalToConstant: 24.scale).isActive = true
        item.customView?.heightAnchor.constraint(equalToConstant: 24.scale).isActive = true
        
        navigationItem.rightBarButtonItem = item
    }
    
    func route(_ route: JoinToCircleViewModel.Route) {
        switch route {
        case .dismiss:
            navigationController?.dismiss(animated: true)
        case .toCircle(let circle):
            let vc = CircleMembersViewController.make(circle: circle)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
