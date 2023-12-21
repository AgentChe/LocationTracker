//
//  LocationViewController.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 21.12.2023.
//

import UIKit
import RxSwift

final class LocationViewController: UIViewController {
    lazy var mainView = LocationView()
    
    private lazy var viewModel = LocationViewModel()
    
    private lazy var disposeBag = DisposeBag()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let output = viewModel.configure(input: LocationViewModel.Input())
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
