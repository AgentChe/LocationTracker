//
//  ConfirmPINViewController.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 12.01.2024.
//

import UIKit
import RxSwift

final class ConfirmPINViewController: UIViewController {
    lazy var mainView = ConfirmPINView()
    
    private lazy var viewModel = ConfirmPINViewModel()
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var feedbackGenerator = UINotificationFeedbackGenerator()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainView.code1Field.becomeFirstResponder()
        
        let output = viewModel.configure(input: ConfirmPINViewModel.Input(
            didInputPIN: mainView.didInputCode
        ))
        
        output.route
            .drive(Binder(self) { base, route in
                base.route(route)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: Public
extension ConfirmPINViewController {
    static func make() -> ConfirmPINViewController {
        let vc = ConfirmPINViewController()
        vc.navigationItem.backButtonTitle = " "
        return vc
    }
}

// MARK: Private
private extension ConfirmPINViewController {
    func route(_ route: ConfirmPINViewModel.Route) {
        switch route {
        case .incorrectPIN:
            feedbackGenerator.notificationOccurred(.error)
            
            mainView.codesFields.forEach { $0.text = "" }
            mainView.code1Field.becomeFirstResponder()
        case .correctPIN:
            let vc = ResetPINViewController.make()
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
