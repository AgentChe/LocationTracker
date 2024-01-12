//
//  ResetPINViewController.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 12.01.2024.
//

import UIKit
import RxSwift

final class ResetPINViewController: UIViewController {
    lazy var mainView = ResetPINView()
    
    private lazy var viewModel = ResetPINViewModel()
    
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
        
        mainView.code1Field.becomeFirstResponder()
        
        let didInputPIN = mainView.continueButton.rx.tap
            .compactMap { [weak self] void -> String? in
                self?.mainView.codesFields
                    .map { $0.text ?? "" }
                    .joined()
            }
            .asSignal(onErrorSignalWith: .never())
        
        let output = viewModel.configure(input: ResetPINViewModel.Input(
            didInputPIN: didInputPIN
        ))
        
        output.activity
            .drive(Binder(self) { base, activity in
                base.activity(activity)
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
extension ResetPINViewController {
    static func make() -> ResetPINViewController {
        let vc = ResetPINViewController()
        vc.navigationItem.title = "ResetPIN.Title".localized
        vc.navigationItem.backButtonTitle = " "
        return vc
    }
}

// MARK: Private
private extension ResetPINViewController {
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
    
    func activity(_ activity: Bool) {
        mainView.continueButton.isHidden = activity
        
        activity ? mainView.preloader.startAnimating() : mainView.preloader.stopAnimating()
    }
    
    func route(_ route: ResetPINViewModel.Route) {
        switch route {
        case .dismiss:
            navigationController?.dismiss(animated: true)
        }
    }
}
