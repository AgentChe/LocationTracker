//
//  CreateCircleCodeViewController.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 07.12.2023.
//

import UIKit
import RxSwift

final class CreateCircleCodeViewController: UIViewController {
    lazy var mainView = CreateCircleCodeView()
    
    private let viewModel: CreateCircleCodeViewModel
    
    private lazy var disposeBag = DisposeBag()
    
    private let flowCompleted: (() -> Void)?
    
    private init(data: CreateCircleCombineData, flowCompleted: (() -> Void)?) {
        self.viewModel = CreateCircleCodeViewModel(data: data)
        self.flowCompleted = flowCompleted
        
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
        
        viewModel.tryAgain = { [weak self] error -> Observable<Void> in
            guard let self = self else {
                return .never()
            }

            return self.open(error: error)
        }
        
        let output = viewModel.configure(input: CreateCircleCodeViewModel.Input(
            didTapDone: mainView.doneButton.rx.tap.asSignal(),
            didTapShare: mainView.inviteButton.rx.tap.asSignal()
        ))
        
        output.activity
            .drive(Binder(self) { base, activity in
                base.activity(activity)
            })
            .disposed(by: disposeBag)
        
        output.route
            .drive(Binder(self) { base, route in
                base.route(route)
            })
            .disposed(by: disposeBag)
        
        output.inviteCode
            .drive(Binder(mainView) { base, inviteCode in
                base.setup(code: inviteCode)
            })
            .disposed(by: disposeBag)
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
extension CreateCircleCodeViewController {
    static func make(data: CreateCircleCombineData, flowCompleted: (() -> Void)? = nil) -> CreateCircleCodeViewController {
        let vc = CreateCircleCodeViewController(data: data, flowCompleted: flowCompleted)
        vc.navigationItem.backButtonTitle = " "
        return vc
    }
}

// MARK: Private
private extension CreateCircleCodeViewController {
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
        mainView.titleLabel.isHidden = activity
        mainView.codeLabel.isHidden = activity
        mainView.subTitleLabel.isHidden = activity
        mainView.inviteButton.isHidden = activity
        mainView.worksTitleLabel.isHidden = activity
        mainView.cell1.isHidden = activity
        mainView.cell2.isHidden = activity
        
        activity ? mainView.preloader.startAnimating() : mainView.preloader.stopAnimating()
    }
    
    func route(_ route: CreateCircleCodeViewModel.Route) {
        switch route {
        case .dismiss:
            navigationController?.dismiss(animated: true) { [weak self] in
                self?.flowCompleted?()
            }
        case .share(let code):
            let controller = UIActivityViewController(activityItems: [code], applicationActivities: nil)
            present(controller, animated: true)
        }
    }
}
