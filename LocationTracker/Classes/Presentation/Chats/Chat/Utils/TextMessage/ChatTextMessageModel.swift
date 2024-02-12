//
//  ChatTextMessageModel.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 08.02.2024.
//

import Chatto
import ChattoAdditions

protocol ChatTextMessageModelProtocol: MessageModelProtocol, ContentEquatableChatItemProtocol {
    var status: MessageStatus { get set }
}

final class ChatTextMessageModel: TextMessageModel<MessageModel>, ChatTextMessageModelProtocol {
    var status: MessageStatus {
        get {
            _messageModel.status
        }
        set {
            _messageModel.status = newValue
        }
    }
}

// MARK: ChatItemType
extension TextMessageModel {
    static var chatItemType: ChatItemType {
        "text"
    }
}
