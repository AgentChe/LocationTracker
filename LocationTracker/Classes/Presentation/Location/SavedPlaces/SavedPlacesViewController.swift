//
//  SavedPlacesViewController.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 11.01.2024.
//

import UIKit
import RxSwift

final class SavedPlacesViewController: UIViewController {
    lazy var mainView = SavedPlacesView()
    
    private lazy var viewModel = SavedPlacesViewModel()
    
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
        
        let output = viewModel.configure(input: SavedPlacesViewModel.Input(
            didSelect: mainView.tableView.didSelect
        ))
        
        output.elements
            .drive(Binder(mainView.tableView) { base, elements in
                base.setup(elements: elements)
            })
            .disposed(by: disposeBag)
        
        output.activity
            .drive(Binder(self) { base, activity in
                base.activity(activity)
            })
            .disposed(by: disposeBag)
        
        output.isEmpty
            .drive(Binder(self) { base, empty in
                base.isEmpty(empty)
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
extension SavedPlacesViewController {
    static func make() -> SavedPlacesViewController {
        let vc = SavedPlacesViewController()
        vc.navigationItem.title = "SavedPlaces.Title".localized
        vc.navigationItem.backButtonTitle = " "
        return vc
    }
}

// MARK: Private
private extension SavedPlacesViewController {
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
        activity ? mainView.preloader.startAnimating() : mainView.preloader.stopAnimating()
    }
    
    func isEmpty(_ empty: Bool) {
        mainView.tableView.isHidden = empty
        mainView.emptyView.isHidden = !empty
    }
    
    func route(_ route: SavedPlacesViewModel.Route) {
        switch route {
        case .edit(let place):
            let vc = EditPlaceViewController.make(place: place)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
