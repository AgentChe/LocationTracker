//
//  CircleConfirmDeleteViewController.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 12.12.2023.
//

import UIKit
import RxSwift

class CircleConfirmDeleteViewController: UIViewController {
    lazy var mainView = CircleConfirmDeleteView()

    private lazy var disposeBag = DisposeBag()
    
    private let delete: () -> Void
    
    private init(delete: @escaping () -> Void) {
        self.delete = delete
        
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
        
        mainView.deleteButton.rx.tap
            .bind(to: Binder(self) { base, void in
                base.dismiss(completion: {
                    base.delete()
                })
            })
            .disposed(by: disposeBag)
        
        mainView.cancelButton.rx.tap
            .bind(to: Binder(self) { base, void in
                base.dismiss()
            })
            .disposed(by: disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        animateShow()
    }
}

// MARK: Make
extension CircleConfirmDeleteViewController {
    static func make(delete: @escaping () -> Void) -> CircleConfirmDeleteViewController {
        let vc = CircleConfirmDeleteViewController(delete: delete)
        vc.modalPresentationStyle = .overFullScreen
        return vc
    }
}

// MARK: Private
private extension CircleConfirmDeleteViewController {
    func animateShow() {
        mainView.containerYConstraint.isActive = false
        mainView.containerYConstraint = mainView.container.bottomAnchor.constraint(equalTo: mainView.bottomAnchor)
        mainView.containerYConstraint.isActive = true

        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.mainView.dimmedView.alpha = 0.6
            self?.mainView.layoutIfNeeded()
        })
    }

    func dismiss(completion: (() -> Void)? = nil) {
        animateDismiss { [weak self] in
            self?.dismiss(animated: false) {
                completion?()
            }
        }
    }
    
    func animateDismiss(completion: @escaping (() -> Void)) {
        mainView.containerYConstraint.isActive = false
        mainView.containerYConstraint = mainView.container.topAnchor.constraint(equalTo: mainView.bottomAnchor)
        mainView.containerYConstraint.isActive = true

        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.mainView.dimmedView.alpha = 0
            self?.mainView.layoutIfNeeded()
        }, completion: { result in
            completion()
        })
    }
}
