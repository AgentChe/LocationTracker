//
//  CreateCircleResponse.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 05.12.2023.
//

import Foundation

enum CreateCircleResponse {
    static func map(from response: Any) -> Circle? {
        guard
            let json = response as? [String: Any],
            let data = json["_data"] as? [String: Any]
        else {
            return nil
        }
        
        return map(circleJSON: data)
    }
    
    static func map(circleJSON: [String: Any]) -> Circle? {
        guard
            let id = circleJSON["id"] as? Int,
            let name = circleJSON["name"] as? String,
            let inviteCode = circleJSON["invite_code"] as? String,
            let ownerJSON = circleJSON["owner"] as? [String: Any],
            let owner = Member(json: ownerJSON)
        else {
            return nil
        }
        
        var image: Image? {
            guard
                let json = circleJSON["image"] as? [String: Any],
                let id = json["file_id"] as? Int,
                let path = json["url"] as? String,
                let url = URL(string: path)
            else {
                return nil
            }
            
            return Image(id: id, url: url)
        }
        
        let membersArray = circleJSON["members"] as? [[String: Any]] ?? []
        let members = membersArray.compactMap { Member(json: $0) }
        
        return Circle(
            id: id,
            name: name,
            image: image,
            inviteCode: inviteCode,
            owner: owner,
            members: members
        )
    }
}
