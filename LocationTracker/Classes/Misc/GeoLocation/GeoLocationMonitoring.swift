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
    
    // TODO: remove
    func geoLocationDidUpdate(locations: [Location]) {
        guard let location = locations.first else {
            return
        }
        
        let coordinate = CLLocation(
            latitude: location.latitude,
            longitude: location.longitude
        )
        
        let locale = Locale(identifier: "ru_RU")
        
        let geoCoder = CLGeocoder()
        
        geoCoder.reverseGeocodeLocation(coordinate, preferredLocale: locale) { result, error in
            var address: String? {
                guard let postalAddress = result?.first?.postalAddress else {
                    return nil
                }
                
                let formatter = CNPostalAddressFormatter()
                formatter.style = .mailingAddress
                
                return formatter.string(from: postalAddress)
            }
            
            guard let address else {
                return
            }
            
            var result = UserDefaults.standard.string(forKey: "test") ?? ""
            
            result += "\n\n"
            result += address
            
            UserDefaults.standard.set(result, forKey: "test")
        }
    }
}
