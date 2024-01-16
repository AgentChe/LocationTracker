//
//  MyTestViewController.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 12.01.2024.
//

import UIKit
import RxSwift

// TODO: Remove MyTest
final class MyTestViewController: UIViewController {
    lazy var mainView = MyTestView()
    
    private lazy var viewModel = MyTestViewModel()
    
    private lazy var disposeBag = DisposeBag()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let output = viewModel.configure(input: MyTestViewModel.Input())
        
        output.elements
            .drive(Binder(mainView.tableView) { base, elements in
                base.setup(elements: elements)
            })
            .disposed(by: disposeBag)
        
        output.activity
            .drive(Binder(mainView.preloader) { base, activity in
                activity ? base.startAnimating() : base.stopAnimating()
            })
            .disposed(by: disposeBag)
    }
}

// MARK: Public
extension MyTestViewController {
    static func make() -> MyTestViewController {
        MyTestViewController()
    }
}
