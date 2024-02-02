//
//  Chat.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 26.01.2024.
//

import Foundation

struct Chat {
    let id: String
    let members: [ChatMember]
    let lastMessage: ChatMessage?
}

// MARK: Public
extension Chat {
    init?(json: [String: Any]) {
        guard
            let id = json["id"] as? String,
            let membersArray = json["members"] as? [[String: Any]]
        else {
            return nil
        }
        
        let members = membersArray.compactMap { ChatMember(json: $0) }
        
        var lastMessage: ChatMessage? {
            guard let lastMessageJSON = json["last_messages"] as? [String: Any] else {
                return nil
            }
            
            return ChatMessage(json: lastMessageJSON)
        }
        
        self = Chat(
            id: id,
            members: members,
            lastMessage: lastMessage
        )
    }
}
