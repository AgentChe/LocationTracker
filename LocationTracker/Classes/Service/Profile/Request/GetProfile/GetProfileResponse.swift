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
        
        var photoUrl: URL? {
            guard let path = data["photo"] as? String else {
                return nil
            }
            
            return URL(string: path)
        }
        
        return Profile(
            name: name,
            photoUrl: photoUrl,
            pin: data["pin"] as? String
        )
    }
}
