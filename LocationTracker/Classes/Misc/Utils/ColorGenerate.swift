//
//  ColorGenerate.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 25.12.2023.
//

import UIKit

final class ColorGenerate {
    enum Constants {
        static let colorsKey = "color_generate_colors_key"
    }
    
    static let shared = ColorGenerate()
    
    private lazy var storage: [String: UIColor] = [:]
 
    private init() {}
}

// MARK: Public
extension ColorGenerate {
    func generate(key: String) -> UIColor {
        if let color = storage[key] {
            return color
        }
        
        let color = UIColor(
            integralRed: CGFloat.random(in: 0...255),
            green: CGFloat.random(in: 0...255),
            blue: CGFloat.random(in: 0...255)
        )
        storage[key] = color
        
        return color
    }
}
