//
//  Fonts.swift
//  Soccer
//
//  Created by Andrey Chernyshev on 16.01.2021.
//

import UIKit

struct Fonts {
    // MARK: RobotoCondensed
    struct RobotoCondensed {
        static func semiBold(size: CGFloat) -> UIFont {
            UIFont(name: "RobotoCondensed-SemiBold", size: size)!
        }
        
        static func medium(size: CGFloat) -> UIFont {
            UIFont(name: "RobotoCondensed-Medium", size: size)!
        }
        
        static func extraBold(size: CGFloat) -> UIFont {
            UIFont(name: "RobotoCondensed-ExtraBold", size: size)!
        }
        
        static func regular(size: CGFloat) -> UIFont {
            UIFont(name: "RobotoCondensed-Regular", size: size)!
        }
        
        static func bold(size: CGFloat) -> UIFont {
            UIFont(name: "RobotoCondensed-Bold", size: size)!
        }
    }
}
