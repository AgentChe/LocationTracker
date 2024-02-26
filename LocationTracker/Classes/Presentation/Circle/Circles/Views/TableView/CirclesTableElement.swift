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
    let selected: Bool
    
    init(
        circle: Circle,
        selected: Bool = false
    ) {
        self.circle = circle
        self.selected = selected
        
        if circle.image != nil {
            self.color = UIColor.clear
        } else {
            self.color = ColorGenerate.shared.generate(key: String(circle.id))
        }
    }
}
