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
        
        if trackInfo.member.photo != nil {
            self.color = UIColor.clear
        } else {
            self.color = ColorGenerate.shared.generate(key: trackInfo.member.id)
        }
        
        var lastUpdated: String? = nil
        if let date = trackInfo.lastPlace?.updated, !me {
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
