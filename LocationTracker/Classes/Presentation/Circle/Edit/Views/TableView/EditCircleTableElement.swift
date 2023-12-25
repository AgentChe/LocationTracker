//
//  EditCircleTableElement.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 12.12.2023.
//

import UIKit

enum EditCircleTableElement {
    case name(EditCircleName)
    case role(Role)
    case membersTitle
    case member(EditCircleMember)
    case addMember
}

struct EditCircleName {
    enum Photo {
        case url(URL?)
        case image(UIImage)
    }
    
    let photo: Photo
    let name: String
}

struct EditCircleMember {
    let member: Member
    let color: UIColor
    
    init(member: Member) {
        self.member = member
        
        if member.photoUrl != nil {
            self.color = UIColor.clear
        } else {
            self.color = ColorGenerate.shared.generate(key: member.id)
        }
    }
}
