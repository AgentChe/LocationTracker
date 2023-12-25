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
    var coordinate: CLLocationCoordinate2D
    let color: UIColor
    
    init?(trackInfo: MemberTrackInfo) {
        guard let location = trackInfo.lastLocation?.asCLLocation else {
            return nil
        }
        
        self.trackInfo = trackInfo
        self.coordinate = location.coordinate
        
        if trackInfo.member.photoUrl != nil {
            self.color = UIColor.clear
        } else {
            self.color = UIColor(
                integralRed: CGFloat.random(in: 0...255),
                green: CGFloat.random(in: 0...255),
                blue: CGFloat.random(in: 0...255)
            )
        }
    }
}
