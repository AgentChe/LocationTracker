//
//  DetailsCircleTableElement.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 11.12.2023.
//

import UIKit

enum DetailsCircleTableElement {
    case title
    case member(DetailsCircleTableMember)
    case action(DetailsCircleTableAction)
}

final class DetailsCircleTableMember {
    let trackInfo: MemberTrackInfo
    let me: Bool
    let address: String?
    let color: UIColor
    let lastUpdated: String?
    
    init(trackInfo: MemberTrackInfo, me: Bool, address: String?) {
        self.trackInfo = trackInfo
        self.me = me
        self.address = address
        
        if trackInfo.member.photoUrl?.host != nil {
            self.color = UIColor.clear
        } else {
            self.color = UIColor(
                integralRed: CGFloat.random(in: 0...255),
                green: CGFloat.random(in: 0...255),
                blue: CGFloat.random(in: 0...255)
            )
        }
        
        var lastUpdated: String? = nil
        if let date = trackInfo.lastUpdated, !me {
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .full
            formatter.locale = Locale(identifier: "en_EN")
            lastUpdated = formatter.localizedString(for: date, relativeTo: Date())
        }
        self.lastUpdated = lastUpdated
    }
}

enum DetailsCircleTableAction {
    case edit, delete, addMember
}
