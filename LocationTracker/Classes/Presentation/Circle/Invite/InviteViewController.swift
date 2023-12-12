//
//  InviteViewController.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 12.12.2023.
//

import UIKit
import RxSwift

final class InviteViewController: UIViewController {
    lazy var mainView = InviteView()
    
    private lazy var disposeBag = DisposeBag()
    
    private let inviteCode: String
    
    private init(inviteCode: String) {
        self.inviteCode = inviteCode
        
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
        
        mainView.doneButton.rx.tap
            .bind(to: Binder(self) { base, void in
                base.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        mainView.inviteButton.rx.tap
            .bind(to: Binder(self) { base, void in
                let controller = UIActivityViewController(activityItems: [base.inviteCode], applicationActivities: nil)
                base.present(controller, animated: true)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: Public
extension InviteViewController {
    static func make(inviteCode: String) -> InviteViewController {
        let vc = InviteViewController(inviteCode: inviteCode)
        vc.navigationItem.backButtonTitle = " "
        return vc
    }
}
