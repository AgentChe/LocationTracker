//
//  GeoLocationManager.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 21.11.2023.
//

import CoreLocation

protocol GeoLocationManagerDelegate: AnyObject {
    func geoLocationDidChange(permissionStatus: GeoLocationPermissionStatus)
    func geoLocationDidUpdate(locations: [Location])
}

final class GeoLocationManager: NSObject {
    static let shared = GeoLocationManager()
    
    private let manager = CLLocationManager()
    
    private var delegates = [Weak<GeoLocationManagerDelegate>]()
    
    private override init() {
        super.init()
        
        manager.allowsBackgroundLocationUpdates = true
        manager.showsBackgroundLocationIndicator = true
        manager.distanceFilter = kCLLocationAccuracyHundredMeters
        manager.pausesLocationUpdatesAutomatically = false
        manager.delegate = self
    }
}

// MARK: Public
extension GeoLocationManager {
    var location: Location? {
        guard let coordinate = manager.location else {
            return nil
        }
        
        return Location(clLocation: coordinate)
    }
    
    func stopUpdatingLocation() {
        manager.stopUpdatingLocation()
    }
    
    func startUpdatingLocation() {
        let status = permissionStatus
        
        guard (status == .authorizedAlways) || (status == .authorizedWhenInUse) else {
            return
        }
        
        manager.stopUpdatingLocation()
        manager.startUpdatingLocation()
    }
    
    func stopMonitoringSignificantLocation() {
        manager.stopMonitoringSignificantLocationChanges()
    }
    
    func startMonitoringSignificantLocation() {
        let status = permissionStatus
        
        guard (status == .authorizedAlways) || (status == .authorizedWhenInUse) else {
            return
        }
        
        manager.stopMonitoringSignificantLocationChanges()
        manager.startMonitoringSignificantLocationChanges()
    }
    
    var permissionStatus: GeoLocationPermissionStatus {
        switch manager.authorizationStatus {
        case .notDetermined:
            return .notDetermined
        case .restricted:
            return .restricted
        case .denied:
            return .denied
        case .authorizedAlways:
            return .authorizedAlways
        case .authorizedWhenInUse:
            return .authorizedWhenInUse
        default:
            return .denied
        }
    }
    
    func requestWhenInUsePermission() {
        manager.requestWhenInUseAuthorization()
    }
    
    func requestAlwaysPermission() {
        manager.requestAlwaysAuthorization()
    }
    
    func add(observer: GeoLocationManagerDelegate) {
        let weakly = observer as AnyObject
        delegates.append(Weak<GeoLocationManagerDelegate>(weakly))
        delegates = delegates.filter { $0.weak != nil }
    }
    
    func remove(observer: GeoLocationManagerDelegate) {
        if let index = delegates.firstIndex(where: { $0.weak === observer }) {
            delegates.remove(at: index)
        }
    }
}

// MARK: CLLocationManagerDelegate
extension GeoLocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async { [weak self] in
            guard let status = self?.permissionStatus else {
                return
            }
            
            self?.delegates.forEach { $0.weak?.geoLocationDidChange(permissionStatus: status) }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let coordinates = locations.map { Location(clLocation: $0) }
        delegates.forEach { $0.weak?.geoLocationDidUpdate(locations: coordinates) }
    }
}
