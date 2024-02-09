//
//  DemoChatMessageFactory.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 08.02.2024.
//

import Foundation
import Chatto
import ChattoAdditions

// TODO
class DemoChatMessageFactory {
    private static let demoText =
        "Lorem ipsum dolor sit amet 😇, https://github.com/badoo/Chatto consectetur adipiscing elit , sed do eiusmod tempor incididunt 07400000000 📞 ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore https://github.com/badoo/Chatto eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat 07400000000 non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."

    class func makeRandomMessage(_ uid: String) -> MessageModelProtocol {
        let isIncoming: Bool = arc4random_uniform(100) % 2 == 0
        return self.makeRandomMessage(uid, isIncoming: isIncoming)
    }

    class func makeRandomMessage(_ uid: String, isIncoming: Bool) -> MessageModelProtocol {
        makeRandomTextMessage(uid, isIncoming: isIncoming)
    }
    
    private class func makeRandomTextMessage(_ uid: String, isIncoming: Bool) -> DemoTextMessageModel {
        let incomingText: String = isIncoming ? "incoming" : "outgoing"
        let maxText = self.demoText
        let length: Int = 10 + Int(arc4random_uniform(300))
        let text = "\(String(maxText[..<maxText.index(maxText.startIndex, offsetBy: length)]))\n\n\(incomingText)\n#\(uid)"
        return self.makeTextMessage(uid, text: text, isIncoming: isIncoming)
    }

    class func makeTextMessage(_ uid: String, text: String, isIncoming: Bool) -> DemoTextMessageModel {
        let messageModel = self.makeMessageModel(uid, isIncoming: isIncoming, type: TextMessageModel<MessageModel>.chatItemType)
        let textMessageModel = DemoTextMessageModel(messageModel: messageModel, text: text)
        return textMessageModel
    }

    private class func makeMessageModel(_ uid: String, isIncoming: Bool, type: String, status: MessageStatus? = nil) -> MessageModel {
        let senderId = isIncoming ? "1" : "2"
        let messageStatus: MessageStatus = {
            guard !isIncoming else { return .success }
            guard let status = status else { return (arc4random_uniform(100) % 3 == 0) ? .success : .failed }
            return status
        }()
        return MessageModel(
            uid: uid,
            senderId: senderId,
            type: type,
            isIncoming: isIncoming,
            date: Date(),
            status: messageStatus,
            canReply: true
        )
    }
}

extension DemoChatMessageFactory {

    private enum DemoMessage {
        case text(String)
    }

    private static let overviewMessages: [DemoMessage] = [
        .text("Welcome to Chatto! A lightweight Swift framework to build chat apps"),
        .text("It calculates sizes in the background for smooth pagination and rotation, and it can deal with thousands of messages with a sliding data source"),
        .text("Along with Chatto there's ChattoAdditions, with bubbles and the input component"),
        .text("This is a TextMessageCollectionViewCell. It uses UITextView with data detectors so you can interact with urls: https://github.com/badoo/Chatto, phone numbers: 07400000000, dates: 3 jan 2016 and others"),
        .text("Those were some PhotoMessageCollectionViewCell. With some fake data transfer"),
        .text("Both Text and Photo cells inherit from BaseMessageCollectionViewCell which adds support for a failed icon and a timestamp you can reveal by swiping from the right"),
        .text("Each message is paired with a Presenter. Each presenter is responsible to present a message by managing a corresponding UICollectionViewCell. New types of messages can be easily added by creating new types of presenters!"),
        .text("Messages have different margins and only some bubbles show a tail. This is done with a decorator that conforms to ChatItemsDecoratorProtocol"),
        .text("Failed/sending status are completly separated cells. This helps to keep cells them simpler. They are generated with the decorator as well, but other approaches are possible, like being returned by the DataSource or using more complex cells"),
        .text("More info on https://github.com/badoo/Chatto. We are waiting for your pull requests!")
    ]

    private static func messages(fromDemoMessages demoMessages: [DemoMessage]) -> [MessageModelProtocol] {
        return demoMessages.map { (demoMessage) in
            let isIncoming: Bool = arc4random_uniform(100) % 2 == 0
            switch demoMessage {
            case .text(let text):
                return DemoChatMessageFactory.makeTextMessage(NSUUID().uuidString, text: text, isIncoming: isIncoming)
            }
        }
    }

    static func makeOverviewMessages() -> [MessageModelProtocol] {
        return self.messages(fromDemoMessages: self.overviewMessages)
    }

    private static let messagesSelectionMessages: [DemoMessage] = [
        .text("Now you have an ability to select chat messages"),
        .text("Press \"Select\" to enter selection mode"),
        .text("Press \"Cancel\" to exit selection mode"),
        .text("In selection mode all interactions with bubbles are disabled"),
        .text("A message can be selected or deselected by tapping on a message cell")
    ]

    static func makeMessagesSelectionMessages() -> [MessageModelProtocol] {
        return self.messages(fromDemoMessages: self.messagesSelectionMessages)
    }
}
