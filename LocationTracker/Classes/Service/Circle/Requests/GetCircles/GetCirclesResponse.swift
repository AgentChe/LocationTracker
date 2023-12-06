//
//  GetCirclesResponse.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 05.12.2023.
//

import Foundation

enum GetCirclesResponse {
    static func map(from response: Any) -> [Circle] {
        guard
            let json = response as? [String: Any],
            let data = json["_data"] as? [[String: Any]]
        else {
            return []
        }
        
        return data.compactMap { json -> Circle? in
            CreateCircleResponse.map(circleJSON: json)
        }
    }
}
