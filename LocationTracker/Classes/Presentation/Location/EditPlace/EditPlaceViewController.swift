//
//  EditPlaceViewController.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 11.01.2024.
//

import UIKit
import RxSwift
import RxCocoa

final class EditPlaceViewController: UIViewController {
    lazy var mainView = EditPlaceView()
    
    private let viewModel: EditPlaceViewModel
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var didDeleteTrigger = PublishRelay<Void>()
    
    private init(place: Place) {
        viewModel = EditPlaceViewModel(place: place)
        
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
                base.confirmDelete()
            })
            .disposed(by: disposeBag)
        
        let output = viewModel.configure(input: EditPlaceViewModel.Input(
            didDelete: didDeleteTrigger.asSignal()
        ))
        
        output.activity
            .drive(Binder(self) { base, activity in
                base.activity(activity)
            })
            .disposed(by: disposeBag)
        
        output.address
            .drive(Binder(mainView) { base, address in
                base.setup(address: address)
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
extension EditPlaceViewController {
    static func make(place: Place) -> EditPlaceViewController {
        let vc = EditPlaceViewController(place: place)
        vc.navigationItem.title = "EditPlace.Title".localized
        vc.navigationItem.backButtonTitle = " "
        return vc
    }
}

// MARK: Private
private extension EditPlaceViewController {
    func activity(_ activity: Bool) {
        mainView.addressPlaceholderLabel.isHidden = activity
        mainView.addressLabel.isHidden = activity
        mainView.deleteButton.isHidden = activity
        
        activity ? mainView.preloader.startAnimating() : mainView.preloader.stopAnimating()
    }
    
    func confirmDelete() {
        let model = ConfirmDeleteViewController.Model(
            title: "EditPlace.Confirm.Title".localized,
            text: "EditPlace.Confirm.Text".localized,
            confirmText: "EditPlace.Delete".localized,
            cancelText: "Cancel".localized
        )
        let vc = ConfirmDeleteViewController.make(model: model) { [weak self] in
            self?.didDeleteTrigger.accept(Void())
        }
        present(vc, animated: false)
    }
    
    func route(_ route: EditPlaceViewModel.Route) {
        switch route {
        case .dismiss:
            navigationController?.popViewController(animated: true)
        }
    }
}
