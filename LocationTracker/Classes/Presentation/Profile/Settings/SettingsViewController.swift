//
//  SettingsViewController.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 26.12.2023.
//

import UIKit
import RxSwift

final class SettingsViewController: UIViewController {
    lazy var mainView = SettingsView()
    
    private lazy var disposeBag = DisposeBag()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Observable
            .merge(
                mainView.contactUsButton.rx.tap
                    .map { GlobalDefinitions.contactUsUrl },
                mainView.privacyPolicyButton.rx.tap
                    .map { GlobalDefinitions.privacyPolicyUrl },
                mainView.termsOfUseButton.rx.tap
                    .map { GlobalDefinitions.termsOfServiceUrl }
            )
            .compactMap { URL(string: $0) }
            .bind(to: Binder(self) { base, url in
                UIApplication.shared.open(url)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: Public
extension SettingsViewController {
    static func make() -> SettingsViewController {
        let vc = SettingsViewController()
        vc.navigationItem.title = "Settings.Title".localized
        vc.navigationItem.backButtonTitle = " "
        return vc
    }
}
