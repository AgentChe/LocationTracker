//
//  ChatMessage.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 26.01.2024.
//

import Foundation

struct ChatMessage {
    let id: Int
    let body: String
    let created: TimeInterval
    let writerId: String
}

// MARK: Public
extension ChatMessage {
    init?(json: [String: Any]) {
        guard
            let id = json["id"] as? Int,
            let body = json["body"] as? String,
            let created = json["created"] as? TimeInterval,
            let writerId = json["writerId"] as? String
        else {
            return nil
        }
        
        self = ChatMessage(
            id: id,
            body: body,
            created: created,
            writerId: writerId
        )
    }
}
