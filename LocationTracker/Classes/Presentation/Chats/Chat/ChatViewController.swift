//
//  ChatViewController.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 07.02.2024.
//

import UIKit
import RxSwift
import RxCocoa
import Chatto
import ChattoAdditions

final class ChatViewController: BaseChatViewController {
    private let viewModel: ChatViewModel
    
    private lazy var disposeBag = DisposeBag()
    
    private var dataSource: ChatDataSource?
    
    private lazy var headerView = ChatHeaderView()
    private lazy var chatInputView = ChatInputView()
    
    private lazy var didSendMessageTrigger = PublishRelay<String>()
    private lazy var didLoadNextPageTrigger = PublishRelay<Int>()
    
    private init(input: ChatInput) {
        viewModel = ChatViewModel(input: input)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        layoutConfiguration = ChatLayoutConfiguration(
            contentInsets: UIEdgeInsets(t: headerView.frame.maxY, b: 16.scale),
            scrollIndicatorInsets: UIEdgeInsets()
        )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let output = viewModel.configure(input: ChatViewModel.Input(
            didTapClose: headerView.closeButton.rx.tap.asSignal(),
            didSendMessage: didSendMessageTrigger.asSignal(),
            didLoadPage: didLoadNextPageTrigger.asSignal()
        ))

        output.partner
            .drive(Binder(self) { base, partner in
                base.headerView.setup(partner: partner.name)
                base.chatInputView.setup(partner: partner)
            })
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
        
        chatItemsDecorator = ChatItemsDecorator()
        
        view.backgroundColor = Appearance.background1
        inputBarContainer.backgroundColor = Appearance.background1
        inputContentContainer.backgroundColor = Appearance.background1
        
        addHeader()
        
        chatInputView.didTapSend = { [weak self] message in
            self?.didSendMessageTrigger.accept(message)
        }
    }
    
    override func createPresenterBuilders() -> [ChatItemType : [ChatItemPresenterBuilderProtocol]] {
        let textMessagePresenter = TextMessagePresenterBuilder(
            viewModelBuilder: ChatTextMessageViewModelBuilder(),
            interactionHandler: MessageInteractionHandler()
        )

        return [
            ChatTextMessageModel.chatItemType: [textMessagePresenter],
            TimeSeparatorModel.chatItemType: [TimeSeparatorPresenterBuilder()],
        ]
    }
    
    override func createChatInputView() -> UIView {
        chatInputView
    }
}

// MARK: Public
extension ChatViewController {
    static func make(member: Member) -> ChatViewController {
        let input = ChatInput(member: member)
        let vc = ChatViewController(input: input)
        vc.navigationItem.backButtonTitle = " "
        vc.modalPresentationStyle = .fullScreen
        return vc
    }
    
    static func make(chat: Chat) -> ChatViewController? {
        guard let input = ChatInput(chat: chat) else {
            return nil
        }
        
        let vc = ChatViewController(input: input)
        vc.navigationItem.backButtonTitle = " "
        vc.modalPresentationStyle = .fullScreen
        return vc
    }
}

// MARK: Private
private extension ChatViewController {
    func action(_ action: ChatViewModel.Action) {
        switch action {
        case .error(let error):
            show(error: error)
        case .page(let chatPage):
            insert(page: chatPage)
        case .chatRemoved:
            route(.dismiss)
        case .newMessage(let chatMessage):
            insert(message: chatMessage)
        }
    }
    
    func insert(page: ChatPage) {
        if let dataSource {
            dataSource.insert(page: page)
        } else {
            let dataSource = ChatDataSource(chatPage: page)
            
            dataSource.didLoadNextPage = { [weak self] page in
                self?.didLoadNextPageTrigger.accept(page)
            }
            
            setChatDataSource(dataSource, triggeringUpdateType: .firstLoad)
            
            self.dataSource = dataSource
        }
    }
    
    func insert(message: ChatMessage) {
        guard let dataSource else {
            return
        }
        
        dataSource.insert(newMessage: message)
    }
    
    func route(_ route: ChatViewModel.Route) {
        switch route {
        case .dismiss:
            dismiss(animated: true)
        }
    }
    
    func addHeader() {
        headerView.backgroundColor = Appearance.background1
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)
        
        NSLayoutConstraint.activate([
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.topAnchor.constraint(equalTo: view.topAnchor)
        ])
    }
    
    func show(error: Error) {
        let vc = TryAgainViewController.make(error: error) { [weak self] in
            self?.route(.dismiss)
        }
        present(vc, animated: true)
    }
}
