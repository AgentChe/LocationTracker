//
//  ChatsViewController.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 02.02.2024.
//

import UIKit
import RxSwift
import RxCocoa

final class ChatsViewController: UIViewController {
    lazy var mainView = ChatsView()
    
    private lazy var viewModel = ChatsViewModel()
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var didRetryConnectTrigger = PublishRelay<Void>()
    private lazy var didDeleteChatTrigger = PublishRelay<Chat>()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainView.tableView
            .didChangeElementsCount
            .emit(to: Binder(self) { base, count in
                base.empty(count == 0)
            })
            .disposed(by: disposeBag)
        
        let output = viewModel.configure(input: ChatsViewModel.Input(
            didConnect: didRetryConnectTrigger.asSignal(),
            didTapMenu: mainView.tableView.didTapMenu,
            didDeleteChat: didDeleteChatTrigger.asSignal(),
            didSelectChat: mainView.tableView.didSelectChat
        ))
        
        output.disposable
            .disposed(by: disposeBag)
        
        output.action
            .drive(Binder(self) { base, action in
                base.action(action)
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
extension ChatsViewController {
    static func make() -> ChatsViewController {
        let vc = ChatsViewController()
        vc.navigationItem.backButtonTitle = " "
        return vc
    }
}

// MARK: Private
private extension ChatsViewController {
    func action(_ action: ChatsViewModel.Action) {
        switch action {
        case .elements(let elements):
            mainView.tableView.setup(elements: elements)
        case .changed(let element):
            mainView.tableView.changed(element: element)
        case .created(let element):
            mainView.tableView.created(element: element)
        case .removed(let id):
            mainView.tableView.removed(id: id)
        case .error(let error):
            show(error: error)
        }
    }
    
    func route(_ route: ChatsViewModel.Route) {
        switch route {
        case .menu(let chat):
            let vc = ChatsMenuViewController.make { [weak self] in
                self?.didDeleteChatTrigger.accept(chat)
            }
            present(vc, animated: false)
        case .chat(let chat):
            guard let vc = ChatViewController.make(chat: chat) else {
                return
            }
            
            present(vc, animated: true)
        }
    }
    
    func empty(_ empty: Bool) {
        mainView.emptyView.isHidden = !empty
        mainView.tableView.isHidden = empty
    }
    
    func show(error: Error) {
        let vc = TryAgainViewController.make(error: error) { [weak self] in
            self?.didRetryConnectTrigger.accept(Void())
        }
        present(vc, animated: true)
    }
}
