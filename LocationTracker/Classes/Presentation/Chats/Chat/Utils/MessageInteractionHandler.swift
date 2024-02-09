//
//  MessageInteractionHandler.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 08.02.2024.
//

import ChattoAdditions

final class MessageInteractionHandler<Model: ChatTextMessageModelProtocol, ViewModel: MessageViewModelProtocol>: BaseMessageInteractionHandlerProtocol {

    func userDidTapOnFailIcon(message: Model, viewModel: ViewModel, failIconView: UIView) {}

    func userDidTapOnAvatar(message: Model, viewModel: ViewModel) {}

    func userDidTapOnBubble(message: Model, viewModel: ViewModel) { }

    func userDidDoubleTapOnBubble(message: Model, viewModel: ViewModel) {}

    func userDidBeginLongPressOnBubble(message: Model, viewModel: ViewModel) {}

    func userDidEndLongPressOnBubble(message: Model, viewModel: ViewModel) {}

    func userDidSelectMessage(message: Model, viewModel: ViewModel) {}

    func userDidDeselectMessage(message: Model, viewModel: ViewModel) {}
}
