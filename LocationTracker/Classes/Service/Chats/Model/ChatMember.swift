//
//  ChatMember.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 26.01.2024.
//

import Foundation

struct ChatMember {
    let id: String
    let name: String
    let photoUrl: URL?
}

// MARK: Public
extension ChatMember {
    init?(json: [String: Any]) {
        guard
            let id = json["id"] as? String,
            let name = json["name"] as? String
        else {
            return nil
        }
        
        var photoUrl: URL? {
            guard let path = json["photoUrl"] as? String else {
                return nil
            }
            
            return URL(string: path)
        }
        
        self = ChatMember(
            id: id,
            name: name,
            photoUrl: photoUrl
        )
    }
}
