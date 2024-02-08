//
//  ChatEventMapper.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 29.01.2024.
//

import Foundation

final class ChatEventMapper {
    func map(from response: String) -> ChatEvent? {
        guard
            let jsonData = response.data(using: .utf8),
            let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
            let result = json["result"] as? [String: Any],
            let event = result["action"] as? String
        else {
            return nil
        }
        
        switch event {
        case "list":
            return list(result: result)
        case "chat_removed":
            return removed(result: result)
        case "new_message":
            return newMessage(result: result)
        default:
            return nil
        }
    }
}

// MARK: Private
private extension ChatEventMapper {
    func list(result: [String: Any]) -> ChatEvent? {
        guard let data = result["data"] as? [String: Any], let page = ChatPage(json: data) else {
            return nil
        }
        
        return .list(page)
    }
    
    func removed(result: [String: Any]) -> ChatEvent? {
        guard let data = result["data"] as? [String: Any], let id = data["id"] as? String else {
            return nil
        }
        
        return .chatRemoved(id)
    }
    
    func newMessage(result: [String: Any]) -> ChatEvent? {
        guard let data = result["result"] as? [String: Any], let message = ChatMessage(json: data) else {
            return nil
        }
        
        return .newMessage(message)
    }
}
