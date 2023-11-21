//
//  GeoLocationPermissionStatus.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 21.11.2023.
//

import CoreLocation

enum GeoLocationPermissionStatus {
    case notDetermined, restricted, denied, authorizedAlways, authorizedWhenInUse
}
