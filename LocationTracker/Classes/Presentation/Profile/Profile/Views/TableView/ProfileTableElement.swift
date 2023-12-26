//
//  ProfileTableElement.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 26.12.2023.
//

import UIKit

enum ProfileTableElement {
    case title
    case edit(ProfileEditElement)
    case menu
}

struct ProfileEditElement {
    let photoUrl: URL?
    let name: String
    let color: UIColor
    
    init(photoUrl: URL?, name: String) {
        self.photoUrl = photoUrl
        self.name = name
        
        if photoUrl != nil {
            self.color = UIColor.clear
        } else {
            self.color = ColorGenerate.shared.generate(key: SessionManager().userId)
        }
    }
}
