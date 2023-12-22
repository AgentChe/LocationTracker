//
//  Location.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 11.12.2023.
//

import CoreLocation

struct Location: Codable {
    let latitude: CGFloat
    let longitude: CGFloat
}

// MARK: Public
extension Location {
    init(clLocation: CLLocation) {
        let coordinate = clLocation.coordinate
        latitude = coordinate.latitude
        longitude = coordinate.longitude
    }
    
    var asCLLocation: CLLocation {
        CLLocation(
            latitude: latitude,
            longitude: longitude
        )
    }
}
