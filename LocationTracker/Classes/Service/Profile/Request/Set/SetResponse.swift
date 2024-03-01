//
//  SetResponse.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 01.03.2024.
//

enum SetResponse {
    typealias ChatId = String
    
    static func map(from response: Any) -> ChatId? {
        guard
            let json = response as? [String: Any],
            let data = json["_data"] as? [String: Any]
        else {
            return nil
        }
        
        return data["chat_identifier"] as? String
    }
}
