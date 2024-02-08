//
//  DemoChatMessageSender.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 08.02.2024.
//

import Chatto
import ChattoAdditions

// TODO
protocol DemoMessageModelProtocol: MessageModelProtocol, ContentEquatableChatItemProtocol {
    var status: MessageStatus { get set }
}

final class DemoChatMessageSender {
    var onMessageChanged: ((_ message: DemoMessageModelProtocol) -> Void)?

    func sendMessages(_ messages: [DemoMessageModelProtocol]) {
        for message in messages {
            fakeMessageStatus(message)
        }
    }

    func sendMessage(_ message: DemoMessageModelProtocol) {
        fakeMessageStatus(message)
    }
}

// MARK: Private
private extension DemoChatMessageSender {
    func fakeMessageStatus(_ message: DemoMessageModelProtocol) {
        switch message.status {
        case .success:
            break
        case .failed:
            updateMessage(message, status: .sending)
            fakeMessageStatus(message)
        case .sending:
            switch arc4random_uniform(100) % 5 {
            case 0:
                if arc4random_uniform(100) % 2 == 0 {
                    updateMessage(message, status: .failed)
                } else {
                    updateMessage(message, status: .success)
                }
            default:
                let delaySeconds: Double = Double(arc4random_uniform(1200)) / 1000.0
                let delayTime = DispatchTime.now() + Double(Int64(delaySeconds * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: delayTime) {
                    fakeMessageStatus(message)
                }
            }
        }
    }

    func updateMessage(_ message: DemoMessageModelProtocol, status: MessageStatus) {
        if message.status != status {
            message.status = status
            notifyMessageChanged(message)
        }
    }

    func notifyMessageChanged(_ message: DemoMessageModelProtocol) {
        onMessageChanged?(message)
    }
}
