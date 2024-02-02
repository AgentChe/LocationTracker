//
//  ChatsEventsMapper.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 29.01.2024.
//

import Foundation

final class ChatsEventsMapper {
    func map(from response: String) -> ChatsEvent? {
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
        case "changed":
            return changed(result: result)
        case "removed":
            return removed(result: result)
        case "created":
            return created(result: result)
        default:
            return nil
        }
    }
}

// MARK: Private
private extension ChatsEventsMapper {
    func list(result: [String: Any]) -> ChatsEvent? {
        guard let data = result["data"] as? [[String: Any]] else {
            return nil
        }
        
        let list = data.compactMap { Chat(json: $0) }
        return .list(list)
    }
    
    func changed(result: [String: Any]) -> ChatsEvent? {
        guard let data = result["data"] as? [String: Any], let chat = Chat(json: data) else {
            return nil
        }
        
        return .changed(chat)
    }
    
    func removed(result: [String: Any]) -> ChatsEvent? {
        guard let data = result["data"] as? [String: Any], let id = data["id"] as? String else {
            return nil
        }
        
        return .removed(id)
    }
    
    func created(result: [String: Any]) -> ChatsEvent? {
        guard let data = result["data"] as? [String: Any], let chat = Chat(json: data) else {
            return nil
        }
        
        return .created(chat)
    }
}
