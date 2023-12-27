//
//  GeoLocationMonitoring.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 21.12.2023.
//

import UIKit
import CoreLocation
import Contacts

final class GeoLocationMonitoring {
    static let shared = GeoLocationMonitoring()
    
    private lazy var manager = GeoLocationManager.shared
    
    private init() {}
}

// MARK: Public
extension GeoLocationMonitoring {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        manager.add(observer: self)
        manager.startMonitoringSignificantLocation()
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        manager.stopMonitoringSignificantLocation()
        manager.startUpdatingLocation()
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        manager.stopUpdatingLocation()
        manager.startMonitoringSignificantLocation()
    }
}

// MARK: GeoLocationManagerDelegate
extension GeoLocationMonitoring: GeoLocationManagerDelegate {
    func geoLocationDidChange(permissionStatus: GeoLocationPermissionStatus) {
        manager.startMonitoringSignificantLocation()
    }
    
    // TODO: send to server
    func geoLocationDidUpdate(locations: [Location]) {
        
    }
}
