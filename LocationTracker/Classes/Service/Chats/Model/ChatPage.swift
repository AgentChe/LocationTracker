//
//  ChatPage.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 01.02.2024.
//

struct ChatPage {
    let messages: [ChatMessage]
    let currentPage: Int
    let allPages: Int
}

// MARK: Public
extension ChatPage {
    init?(json: [String: Any]) {
        guard
            let messagesArray = json["data"] as? [[String: Any]],
            let paginationJSON = json["pagination"] as? [String: Any],
            let currentPage = paginationJSON["current_page"] as? Int,
            let allPages = paginationJSON["all_pages"] as? Int
        else {
            return nil
        }
        
        let messages = messagesArray.compactMap { ChatMessage(json: $0) }
        
        self = ChatPage(
            messages: messages,
            currentPage: currentPage,
            allPages: allPages
        )
    }
}
