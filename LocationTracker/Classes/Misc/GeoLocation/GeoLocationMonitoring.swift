//
//  GeoLocationMonitoring.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 21.12.2023.
//

import UIKit
import CoreLocation
import Contacts
import RxSwift

final class GeoLocationMonitoring {
    static let shared = GeoLocationMonitoring()
    
    private lazy var manager = GeoLocationManager.shared
    private lazy var trackManager = TrackManager()
    
    private lazy var disposeBag = DisposeBag()
    
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
    
    func geoLocationDidUpdate(locations: [Location]) {
        guard let location = locations.first else {
            return
        }
        
        trackManager
            .saveGeo(location: location)
            .subscribe()
            .disposed(by: disposeBag)
    }
}
