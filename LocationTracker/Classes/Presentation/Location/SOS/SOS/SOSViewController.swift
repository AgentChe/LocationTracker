//
//  SOSViewController.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 16.01.2024.
//

import UIKit
import RxSwift
import RxCocoa

final class SOSViewController: UIViewController {
    lazy var mainView = SOSView(circle: circle)
    
    private lazy var viewModel = SOSViewModel(circle: circle)
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var didTapSOSTrigger = PublishRelay<Void>()
    
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
        
        let output = viewModel.configure(input: SOSViewModel.Input(
            didTapClose: mainView.closeButton.rx.tap.asSignal(),
            didTapInstruction: mainView.instructionButton.rx.tap.asSignal(),
            didTapSOS: didTapSOSTrigger.asSignal()
        ))
        
        output.route
            .drive(Binder(self) { base, route in
                base.route(route)
            })
            .disposed(by: disposeBag)
        
        output.pin
            .drive(Binder(mainView) { base, pin in
                base.setup(pin: pin)
            })
            .disposed(by: disposeBag)
        
        addSOSActions()
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
extension SOSViewController {
    static func make(circle: Circle) -> SOSViewController {
        let vc = SOSViewController(circle: circle)
        vc.navigationItem.backButtonTitle = " "
        return vc
    }
}

// MARK: Private
private extension SOSViewController {
    func route(_ route: SOSViewModel.Route) {
        switch route {
        case .dismiss:
            navigationController?.dismiss(animated: true)
        case .instruction:
            let vc = SOSInstructionViewController.make()
            present(vc, animated: true)
        case .signal:
            break // TODO
        }
    }
    
    func addSOSActions() {
        Observable
            .merge(
                mainView.sosButton.rx
                    .controlEvent(.touchDown)
                    .map { SOSActiveButton.Action.touchDown },
                
                mainView.sosButton.rx
                    .controlEvent(.touchUpInside)
                    .map { SOSActiveButton.Action.touchUpInside },
                
                mainView.sosButton.rx
                    .controlEvent(.touchUpOutside)
                    .map { SOSActiveButton.Action.touchUpOutside }
            )
            .bind(to: Binder(self) { base, action in
                base.mainView.setup(action: action)
                
                if action == .touchUpInside {
                    base.didTapSOSTrigger.accept(Void())
                }
            })
            .disposed(by: disposeBag)
    }
}
