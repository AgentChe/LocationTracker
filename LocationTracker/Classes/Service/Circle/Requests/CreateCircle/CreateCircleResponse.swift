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
            let photoPath = circleJSON["image"] as? String,
            let photoUrl = URL(string: photoPath),
            let inviteCode = circleJSON["invite_code"] as? String,
            let ownerJSON = circleJSON["owner"] as? [String: Any],
            let owner = map(memberJSON: ownerJSON)
        else {
            return nil
        }
        
        let membersArray = circleJSON["members"] as? [[String: Any]] ?? []
        let members = membersArray.compactMap { map(memberJSON: $0) }
        
        return Circle(
            id: id,
            name: name,
            imageUrl: photoUrl,
            inviteCode: inviteCode,
            owner: owner,
            members: members
        )
    }
    
    static func map(memberJSON: [String: Any]) -> Member? {
        guard
            let id = memberJSON["id"] as? String,
            let name = memberJSON["name"] as? String,
            let photoPath = memberJSON["image"] as? String,
            let photoUrl = URL(string: photoPath),
            let roleId = memberJSON["role_id"] as? Int
        else {
            return nil
        }
        
        return Member(
            id: id,
            name: name,
            photoUrl: photoUrl,
            roleId: roleId
        )
    }
}
