//
//  GetProfileResponse.swift
//  Soccer
//
//  Created by Андрей Чернышев on 03.02.2023.
//

import Foundation

final class GetProfileResponse {
    static func map(from response: Any) -> Profile? {
        guard
            let json = response as? [String: Any],
            let data = json["_data"] as? [String: Any],
            let name = data["name"] as? String
        else {
            return nil
        }
        
        var photo: Image? {
            guard
                let json = data["image"] as? [String: Any],
                let id = json["file_id"] as? Int,
                let path = json["url"] as? String,
                let url = URL(string: path)
            else {
                return nil
            }
            
            return Image(id: id, url: url)
        }
        
        return Profile(
            name: name,
            photo: photo,
            pin: data["pin"] as? String
        )
    }
}
