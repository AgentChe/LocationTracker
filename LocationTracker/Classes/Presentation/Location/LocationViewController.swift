//
//  LocationViewController.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 21.12.2023.
//

import UIKit
import RxSwift
import MapKit

final class LocationViewController: UIViewController {
    lazy var mainView = LocationView()
    
    private lazy var viewModel = LocationViewModel()
    
    private lazy var disposeBag = DisposeBag()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let output = viewModel.configure(input: LocationViewModel.Input(
            didMoveToMyCoordinate: mainView.myCoordinateButton.rx.tap.asSignal()
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
    func moveToMy(coordinate: Location) {
        let region = MKCoordinateRegion(center: coordinate.asCLLocation.coordinate, latitudinalMeters: 200, longitudinalMeters: 200)
        mainView.mapView.setRegion(region, animated: false)
    }
}
