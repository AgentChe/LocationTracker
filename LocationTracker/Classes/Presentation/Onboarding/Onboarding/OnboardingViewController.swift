//
//  OnboardingViewController.swift
//  Soccer
//
//  Created by Андрей Чернышев on 23.08.2022.
//

import UIKit
import RxSwift

final class OnboardingViewController: UIViewController {
    struct Constants {
        static let wasViewedKey = "onboarding_view_controller_was_viewed_key"
    }
    
    lazy var mainView = OnboardingView(vc: self)
    
    private lazy var disposeBag = DisposeBag()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainView.didFinish = { [weak self] in
            self?.markAsViewed()
            self?.goToNext()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }
}

// MARK: Make
extension OnboardingViewController {
    static func make() -> OnboardingViewController {
        OnboardingViewController()
    }
}

// MARK: Public
extension OnboardingViewController {
    static func wasViewed() -> Bool {
        UserDefaults.standard.bool(forKey: OnboardingViewController.Constants.wasViewedKey)
    }
}

// MARK: Private
private extension OnboardingViewController {
    func markAsViewed() {
        UserDefaults.standard.setValue(true, forKey: Constants.wasViewedKey)
    }
    
    func goToNext() {
        if SessionManager().hasActiveSubscriptions() {
            UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.rootViewController = MainViewController.make()
        } else {
            let vc = PaygateViewController.make()
            vc.didClose = {
                UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.rootViewController = MainViewController.make()
            }
            present(vc, animated: true)
        }
    }
}
