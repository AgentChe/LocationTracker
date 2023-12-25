//
//  LocationViewController.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 21.12.2023.
//

import UIKit
import RxSwift
import RxCocoa
import MapKit

final class LocationViewController: UIViewController {
    lazy var mainView = LocationView()
    
    private lazy var viewModel = LocationViewModel()
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var didSelectCircleTrigger = PublishRelay<Circle>()
    private lazy var didDeleteCircleTrigger = PublishRelay<Circle>()
    
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
        
        let output = viewModel.configure(input: LocationViewModel.Input(
            didMoveToMyCoordinate: mainView.myCoordinateButton.rx.tap.asSignal(),
            didSelectCircle: didSelectCircleTrigger.asSignal(),
            didSelectElement: mainView.circleView.tableView.didSelect,
            didDeleteCircle: didDeleteCircleTrigger.asSignal()
        ))
        
        output.moveToMyCoordinate
            .drive(Binder(self) { base, coordinate in
                base.moveToMy(coordinate: coordinate)
            })
            .disposed(by: disposeBag)
        
        output.meAnnotation
            .drive(Binder(mainView.mapView) { base, meAnnotation in
                base.setup(me: meAnnotation)
            })
            .disposed(by: disposeBag)
        
        output.activity
            .drive(Binder(mainView.circleView) { base, activity in
                base.tableView.isHidden = activity
                activity ? base.preloader.startAnimating() : base.preloader.stopAnimating()
            })
            .disposed(by: disposeBag)
        
        output.circleElements
            .drive(Binder(mainView.circleView.tableView) { base, elements in
                base.setup(elements: elements)
            })
            .disposed(by: disposeBag)
        
        output.route
            .drive(Binder(self) { base, route in
                base.route(route)
            })
            .disposed(by: disposeBag)
        
        output.disposable
            .disposed(by: disposeBag)
    }
}

// MARK: Public
extension LocationViewController {
    static func make() -> LocationViewController {
        let vc = LocationViewController()
        vc.navigationItem.backButtonTitle = " "
        return vc
    }
}

// MARK: Private
private extension LocationViewController {
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
    
    func moveToMy(coordinate: Location) {
        let region = MKCoordinateRegion(center: coordinate.asCLLocation.coordinate, latitudinalMeters: 200, longitudinalMeters: 200)
        mainView.mapView.setRegion(region, animated: false)
    }
    
    func route(_ route: LocationViewModel.Route) {
        switch route {
        case .trackInfo(let memberTrackInfo):
            break // TODO
        case .addMember(let inviteCode):
            let vc = InviteViewController.make(inviteCode: inviteCode)
            present(vc, animated: true)
        case .edit(let circle):
            let vc = EditCircleViewController.make(circle: circle)
            navigationController?.pushViewController(vc, animated: true)
        case .delete(let circle):
            let vc = CircleConfirmDeleteViewController.make { [weak self] in
                self?.didDeleteCircleTrigger.accept(circle)
            }
            present(vc, animated: false)
        case .select(let circle):
            break // TODO
        case .createCircle:
            let vc = CreateCircleViewController.make(mode: .flow)
            let nc = NavigationController(rootViewController: vc)
            present(nc, animated: true)
        }
    }
}
