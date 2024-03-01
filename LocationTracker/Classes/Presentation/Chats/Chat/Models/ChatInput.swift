//
//  ChatInput.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 07.02.2024.
//

import Foundation

struct ChatInput {
    let partnerName: String
    let partnerId: String
    let partnerAvatarUrl: URL?
    
    init(member: Member) {
        partnerName = member.name
        partnerId = member.chatId ?? ""
        partnerAvatarUrl = member.photo?.url
    }
    
    init?(chat: Chat) {
        let userId = SessionManager().userId
        
        guard let member = chat.members.first(where: { $0.id != userId }) else {
            return nil
        }
        
        partnerName = member.name
        partnerId = member.id
        partnerAvatarUrl = member.photoUrl
    }
}
