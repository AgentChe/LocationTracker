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
                let member = CreateCircleResponse.map(memberJSON: memberJSON)
            else {
                return nil
            }
            
            var location: Location? {
                guard
                    let locationJSON = json["location"] as? [String: Any],
                    let latitude = locationJSON["latitude"] as? CGFloat,
                    let longitude = locationJSON["longitude"] as? CGFloat
                else {
                    return nil
                }
                
                return Location(
                    latitude: latitude,
                    longitude: longitude
                )
            }
            
            var lastUpdated: Date? {
                guard let lastUpdatedTimestamp = json["last_updated"] as? TimeInterval else {
                    return nil
                }
                
                return Date(timeIntervalSince1970: lastUpdatedTimestamp)
            }
            
            return MemberTrackInfo(
                member: member,
                lastLocation: location,
                lastUpdated: lastUpdated,
                batteryLevel: json["battery_level"] as? Float
            )
        }
    }
}
