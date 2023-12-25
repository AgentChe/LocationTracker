//
//  MeAnnotation.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 22.12.2023.
//

import MapKit
import UIKit

final class MeAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var photoUrl: URL?
    let color: UIColor
    
    init(
        coordinate: CLLocationCoordinate2D,
        photoUrl: URL?
    ) {
        self.coordinate = coordinate
        self.photoUrl = photoUrl
        
        if photoUrl != nil {
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
