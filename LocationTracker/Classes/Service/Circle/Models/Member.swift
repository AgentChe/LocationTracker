//
//  Member.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 05.12.2023.
//

import Foundation

struct Member: Codable, Hashable {
    let id: String
    let name: String
    let photo: Image?
    let roleId: Int?
    let chatId: String?
    let sos: Bool
}

// MARK: Public
extension Member {
    init?(json: [String: Any]) {
        guard
            let id = json["id"] as? String,
            let name = json["name"] as? String
        else {
            return nil
        }
        
        var image: Image? {
            guard
                let json = json["image"] as? [String: Any],
                let id = json["file_id"] as? Int,
                let path = json["url"] as? String,
                let url = URL(string: path)
            else {
                return nil
            }
            
            return Image(id: id, url: url)
        }
        
        self = Member(
            id: id,
            name: name,
            photo: image,
            roleId: json["role_id"] as? Int,
            chatId: json["chat_identifier"] as? String,
            sos: json["sos"] as? Bool ?? false
        )
    }
}
