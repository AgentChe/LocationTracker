//
//  ChatTextMessageViewModelBuilder.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 08.02.2024.
//

import Chatto
import ChattoAdditions

typealias ChatTextMessageViewModel = TextMessageViewModel<ChatTextMessageModel>

final class ChatTextMessageViewModelBuilder: ViewModelBuilderProtocol {
    let messageViewModelBuilder = MessageViewModelDefaultBuilder()

    func createViewModel(_ textMessage: ChatTextMessageModel) -> ChatTextMessageViewModel {
        let messageViewModel = messageViewModelBuilder.createMessageViewModel(textMessage)
        let textMessageViewModel = ChatTextMessageViewModel(textMessage: textMessage, messageViewModel: messageViewModel)
        return textMessageViewModel
    }

    func canCreateViewModel(fromModel model: Any) -> Bool {
        return model is ChatTextMessageModel
    }
}
