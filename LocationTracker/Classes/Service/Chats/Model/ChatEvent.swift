//
//  ChatEvent.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 29.01.2024.
//

enum ChatEvent {
    case chatId(String)
    case list(ChatPage)
    case chatRemoved(String)
    case newMessage(ChatMessage)
}
