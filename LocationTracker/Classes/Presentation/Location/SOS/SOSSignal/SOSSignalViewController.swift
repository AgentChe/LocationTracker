//
//  SOSSignalViewController.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 17.01.2024.
//

import UIKit
import RxSwift
import RxCocoa

final class SOSSignalViewController: UIViewController {
    lazy var mainView = SOSSignalView()
    
    private lazy var viewModel = SOSSignalViewModel(sos: sos)
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var feedbackGenerator = UINotificationFeedbackGenerator()
    
    private var timer: Timer?
    
    private lazy var didTimerTickTrigger = PublishRelay<Void>()
    private lazy var didCancelSignalTrigger = PublishRelay<Void>()
    
    private let sos: SOS
    
    private init(sos: SOS) {
        self.sos = sos
        
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
        
        let output = viewModel.configure(input: SOSSignalViewModel.Input(
            didTapClose: mainView.closeButton.rx.tap.asSignal(),
            didTimerTick: didTimerTickTrigger.asSignal(),
            didInputCode: mainView.didInputCode,
            didCancelSignal: didCancelSignalTrigger.asSignal()
        ))
        
        output.route
            .drive(Binder(self) { base, route in
                base.route(route)
            })
            .disposed(by: disposeBag)
        
        output.progress
            .drive(mainView.progressView.rx.progress)
            .disposed(by: disposeBag)
        
        output.secondsLeft
            .drive(Binder(mainView) { base, seconds in
                base.setup(seconds: seconds)
            })
            .disposed(by: disposeBag)
        
        output.activity
            .drive(Binder(self) { base, activity in
                base.activity(activity)
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        mainView.endEditing(true)
    }
}

// MARK: Public
extension SOSSignalViewController {
    static func make(sos: SOS) -> SOSSignalViewController {
        let vc = SOSSignalViewController(sos: sos)
        vc.navigationItem.backButtonTitle = " "
        return vc
    }
}

// MARK: Private
private extension SOSSignalViewController {
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
    
    func route(_ route: SOSSignalViewModel.Route) {
        switch route {
        case .dismiss:
            navigationController?.dismiss(animated: true)
        case.startTimer:
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
                self?.didTimerTickTrigger.accept(Void())
            }
        case .stopTimer:
            timer?.invalidate()
            timer = nil
        case .signalSended:
            mainView.sendedLabel.isHidden = false
        case .incorrectCode:
            feedbackGenerator.notificationOccurred(.error)
            
            mainView.codesFields.forEach { $0.text = "" }
            mainView.code1Field.becomeFirstResponder()
        case .confirmCancel:
            let model = ConfirmDeleteViewController.Model(
                title: "SOSConfirmCancel.Title".localized,
                text: "SOSConfirmCancel.Text".localized,
                confirmText: "SOSConfirmCancel.WaitButton".localized,
                cancelText: "SOSConfirmCancel.CancelButton".localized
            )
            let vc = ConfirmDeleteViewController.make(model: model, cancel: { [weak self] in
                self?.didCancelSignalTrigger.accept(Void())
            })
            present(vc, animated: true)
        }
    }
    
    func activity(_ activity: Bool) {
        activity ? mainView.preloader.startAnimating() : mainView.preloader.stopAnimating()
    }
}
