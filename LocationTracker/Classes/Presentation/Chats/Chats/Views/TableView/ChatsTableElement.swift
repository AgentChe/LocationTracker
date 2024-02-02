//
//  ChatsTableElement.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 02.02.2024.
//

import Foundation

struct ChatsTableElement {
    let chat: Chat
    let partner: ChatMember
    let time: String?
    
    init?(chat: Chat, userId: String) {
        guard let partner = chat.members.first(where: { $0.id != userId }) else {
            return nil
        }
        
        self.chat = chat
        self.partner = partner
        
        if let created = chat.lastMessage?.created {
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .short
            formatter.locale = Locale(identifier: "en_EN")
            self.time = formatter.localizedString(for: Date(timeIntervalSince1970: created), relativeTo: Date())
        } else {
            self.time = nil
        }
    }
}
