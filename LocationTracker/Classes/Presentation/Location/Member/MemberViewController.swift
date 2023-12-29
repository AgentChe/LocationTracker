//
//  MemberViewController.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 27.12.2023.
//

import UIKit
import RxSwift

final class MemberViewController: UIViewController {
    lazy var mainView = MemberView()
    
    private let viewModel: MemberViewModel
    
    private lazy var disposeBag = DisposeBag()
    
    private init(memberTrackInfo: MemberTrackInfo) {
        viewModel = MemberViewModel(memberTrackInfo: memberTrackInfo)
        
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
        
        let output = viewModel.configure(input: MemberViewModel.Input(
            didRefresh: mainView.tableView.didRefreshCurrentPlace
        ))
        
        output.elements
            .drive(Binder(mainView.tableView) { base, elements in
                base.setup(elements: elements)
            })
            .disposed(by: disposeBag)
        
        addSwipeAction()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        mainView.animateShow()
    }
}

// MARK: Public
extension MemberViewController {
    static func make(memberTrackInfo: MemberTrackInfo) -> MemberViewController {
        let vc = MemberViewController(memberTrackInfo: memberTrackInfo)
        vc.modalPresentationStyle = .overFullScreen
        return vc
    }
}

// MARK: Private
private extension MemberViewController {
    enum ContainerState: Hashable {
        case medium, large
    }
    
    enum SwipeDirection: Hashable {
        case up, down
    }
    
    enum SwipeAction: Hashable {
        case changeState(ContainerState), dismiss
    }
    
    func addSwipeAction() {
        let swipeUpGesture = UISwipeGestureRecognizer()
        swipeUpGesture.direction = .up
        
        let swipeDownGesture = UISwipeGestureRecognizer()
        swipeDownGesture.direction = .down
        
        mainView.swipeArea.isUserInteractionEnabled = true
        mainView.swipeArea.addGestureRecognizer(swipeUpGesture)
        mainView.swipeArea.addGestureRecognizer(swipeDownGesture)
        
        let swipeDirection = Observable
            .merge(
                swipeUpGesture.rx.event
                    .map { event in SwipeDirection.up },
                swipeDownGesture.rx.event
                    .map { event in SwipeDirection.down }
            )
        
        let action = swipeDirection
            .scan(SwipeAction.changeState(.medium)) { action, direction -> SwipeAction in
                switch direction {
                case .up:
                    return .changeState(.large)
                case .down:
                    switch action {
                    case .changeState(let state):
                        switch state {
                        case .large:
                            return .changeState(.medium)
                        case .medium:
                            return .dismiss
                        }
                    case .dismiss:
                        return .dismiss
                    }
                }
            }
            .distinctUntilChanged()
        
        action
            .asDriver(onErrorDriveWith: .never())
            .drive(Binder(self) { base, action in
                base.swipeAction(action)
            })
            .disposed(by: disposeBag)
    }
    
    func swipeAction(_ action: SwipeAction) {
        switch action {
        case .changeState(let state):
            switch state {
            case .large:
                mainView.large()
            case .medium:
                mainView.medium()
            }
        case .dismiss:
            dismiss()
        }
    }
    
    func dismiss(completion: (() -> Void)? = nil) {
        mainView.animateDismiss { [weak self] in
            self?.dismiss(animated: false) {
                completion?()
            }
        }
    }
    
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
}
