//
//  CirclesTableElement.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 06.12.2023.
//

import UIKit

struct CirclesTableElement {
    let circle: Circle
    let color: UIColor
    
    init(circle: Circle) {
        self.circle = circle
        
        if circle.imageUrl != nil {
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
