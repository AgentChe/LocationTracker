//
//  DemoTextMessageModel.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 08.02.2024.
//

import Chatto
import ChattoAdditions

protocol DemoMessageModelProtocol: MessageModelProtocol, ContentEquatableChatItemProtocol {
    var status: MessageStatus { get set }
}

// TODO
final class DemoTextMessageModel: TextMessageModel<MessageModel>, DemoMessageModelProtocol {
    public override init(messageModel: MessageModel, text: String) {
        super.init(messageModel: messageModel, text: text)
    }

    public var status: MessageStatus {
        get {
            return self._messageModel.status
        }
        set {
            self._messageModel.status = newValue
        }
    }
}
