//
//  ChatsEvent.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 29.01.2024.
//

enum ChatsEvent {
    case list([Chat])
    case changed(Chat)
    case removed(String)
    case created(Chat)
}
