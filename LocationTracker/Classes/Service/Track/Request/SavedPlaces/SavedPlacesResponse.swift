//
//  SavedPlacesResponse.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 28.12.2023.
//

import Foundation

enum SavedPlacesResponse {
    static func map(from response: Any) -> [Place] {
        guard
            let json = response as? [String: Any],
            let data = json["_data"] as? [[String: Any]]
        else {
            return []
        }
        
        return data.compactMap { json -> Place? in
            guard
                let id = json["id"] as? Int,
                let locationJSON = json["location"] as? [String: Any],
                let latitude = locationJSON["latitude"] as? CGFloat,
                let longitude = locationJSON["longitude"] as? CGFloat,
                let lastUpdatedTimestamp = json["last_updated"] as? TimeInterval
            else {
                return nil
            }

            let location = Location(
                latitude: latitude,
                longitude: longitude
            )

            return Place(
                id: id,
                location: location,
                updated: Date(timeIntervalSince1970: lastUpdatedTimestamp)
            )
        }
    }
}
