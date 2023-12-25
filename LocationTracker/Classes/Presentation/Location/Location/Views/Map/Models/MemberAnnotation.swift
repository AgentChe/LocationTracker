//
//  MemberAnnotation.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 22.12.2023.
//

import MapKit
import UIKit

final class MemberAnnotation: NSObject, MKAnnotation {
    let trackInfo: MemberTrackInfo
    let me: Bool
    let coordinate: CLLocationCoordinate2D
    let color: UIColor
    
    init?(trackInfo: MemberTrackInfo, me: Bool) {
        guard let location = trackInfo.lastLocation?.asCLLocation else {
            return nil
        }
        
        self.trackInfo = trackInfo
        self.me = me
        self.coordinate = location.coordinate
        
        if trackInfo.member.photoUrl != nil {
            self.color = UIColor.clear
        } else {
            self.color = ColorGenerate.shared.generate(key: trackInfo.member.id)
        }
    }
}
