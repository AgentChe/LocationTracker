//
//  CircleMembersViewController.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 09.12.2023.
//

import UIKit
import RxSwift

final class CircleMembersViewController: UIViewController {
    lazy var mainView = CircleMembersView()
    
    private lazy var disposeBag = DisposeBag()
    
    private let circle: Circle
    
    private init(circle: Circle) {
        self.circle = circle
        
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
        
        Observable
            .merge(
                mainView.closeButton.rx.tap.asObservable(),
                mainView.okButton.rx.tap.asObservable()
            )
            .bind(to: Binder(self) { base, void in
                base.navigationController?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        mainView.setup(name: circle.name, memebers: circle.members)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
}

// MARK: Public
extension CircleMembersViewController {
    static func make(circle: Circle) -> CircleMembersViewController {
        let vc = CircleMembersViewController(circle: circle)
        vc.navigationItem.backButtonTitle = " "
        return vc
    }
}
