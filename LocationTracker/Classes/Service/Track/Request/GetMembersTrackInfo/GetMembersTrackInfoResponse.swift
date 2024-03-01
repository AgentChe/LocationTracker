//
//  GetMembersTrackInfoResponse.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 11.12.2023.
//

import Foundation

enum GetMembersTrackInfoResponse {
    static func map(from response: Any) -> [MemberTrackInfo] {
        guard
            let json = response as? [String: Any],
            let data = json["_data"] as? [[String: Any]]
        else {
            return []
        }
        
        return data.compactMap { json -> MemberTrackInfo? in
            guard
                let memberJSON = json["member"] as? [String: Any],
                let member = Member(json: memberJSON)
            else {
                return nil
            }
            
            var place: Place? {
                guard
                    let placeJSON = json["place"] as? [String: Any],
                    let id = placeJSON["id"] as? Int,
                    let locationJSON = placeJSON["location"] as? [String: Any],
                    let latitude = locationJSON["latitude"] as? CGFloat,
                    let longitude = locationJSON["longitude"] as? CGFloat,
                    let lastUpdatedTimestamp = placeJSON["last_updated"] as? TimeInterval
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
            
            return MemberTrackInfo(
                member: member,
                lastPlace: place,
                batteryLevel: json["battery_level"] as? Int
            )
        }
    }
}
