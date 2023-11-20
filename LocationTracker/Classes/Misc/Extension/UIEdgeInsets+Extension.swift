//
//  UIEdgeInsets+Extension.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 20.11.2023.
//

import UIKit

extension UIEdgeInsets {
    init(value: CGFloat) {
        self = UIEdgeInsets(top: value, left: value, bottom: value, right: value)
    }
    
    init(vertical: CGFloat = 0, horizontal: CGFloat = 0) {
        self = UIEdgeInsets(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
    }
}
