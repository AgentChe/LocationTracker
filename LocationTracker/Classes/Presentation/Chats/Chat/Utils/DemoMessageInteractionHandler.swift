//
//  DemoMessageInteractionHandler.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 08.02.2024.
//

import ChattoAdditions

final class DemoMessageInteractionHandler<Model: DemoMessageModelProtocol, ViewModel: MessageViewModelProtocol>: BaseMessageInteractionHandlerProtocol {

    init(messageSender: DemoChatMessageSender, messagesSelector: MessagesSelectorProtocol) {
        self.messageSender = messageSender
        self.messagesSelector = messagesSelector
    }

    private let messageSender: DemoChatMessageSender
    private let messagesSelector: MessagesSelectorProtocol

    func userDidTapOnFailIcon(message: Model, viewModel: ViewModel, failIconView: UIView) {
        print(#function)
        self.messageSender.sendMessage(message)
    }

    func userDidTapOnAvatar(message: Model, viewModel: ViewModel) {
        print(#function)
    }

    func userDidTapOnBubble(message: Model, viewModel: ViewModel) {
        print(#function)
    }

    func userDidDoubleTapOnBubble(message: Model, viewModel: ViewModel) {
        print(#function)
    }

    func userDidBeginLongPressOnBubble(message: Model, viewModel: ViewModel) {
        print(#function)
    }

    func userDidEndLongPressOnBubble(message: Model, viewModel: ViewModel) {
        print(#function)
    }

    func userDidSelectMessage(message: Model, viewModel: ViewModel) {
        print(#function)
        self.messagesSelector.selectMessage(message)
    }

    func userDidDeselectMessage(message: Model, viewModel: ViewModel) {
        print(#function)
        self.messagesSelector.deselectMessage(message)
    }
}
