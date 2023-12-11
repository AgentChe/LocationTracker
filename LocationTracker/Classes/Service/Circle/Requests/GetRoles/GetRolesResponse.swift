//
//  GetRolesResponse.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 05.12.2023.
//

enum GetRolesResponse {
    static func map(from response: Any) -> [Role] {
        guard
            let json = response as? [String: Any],
            let data = json["_data"] as? [[String: Any]]
        else {
            return []
        }
        
        return data.compactMap { json -> Role? in
            guard
                let id = json["id"] as? Int,
                let name = json["name"] as? String
            else {
                return nil
            }
            
            return Role(
                id: id,
                name: name
            )
        }
    }
}
