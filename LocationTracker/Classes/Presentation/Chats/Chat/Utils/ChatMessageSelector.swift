//
//  ChatMessageSelector.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 08.02.2024.
//

import ChattoAdditions
import Foundation

final class ChatMessageSelector: MessagesSelectorProtocol {
    weak var delegate: MessagesSelectorDelegate?
    
    private var selectedMessagesDictionary = [String: MessageModelProtocol]()

    var isActive = false {
        didSet {
            if oldValue != isActive, isActive {
                selectedMessagesDictionary.removeAll()
            }
        }
    }

    func canSelectMessage(_ message: MessageModelProtocol) -> Bool {
        true
    }

    func isMessageSelected(_ message: MessageModelProtocol) -> Bool {
        selectedMessagesDictionary[message.uid] != nil
    }

    func selectMessage(_ message: MessageModelProtocol) {
        selectedMessagesDictionary[message.uid] = message
        delegate?.messagesSelector(self, didSelectMessage: message)
    }

    func deselectMessage(_ message: MessageModelProtocol) {
        selectedMessagesDictionary[message.uid] = nil
        delegate?.messagesSelector(self, didDeselectMessage: message)
    }

    func selectedMessages() -> [MessageModelProtocol] {
        Array(selectedMessagesDictionary.values)
    }
}
