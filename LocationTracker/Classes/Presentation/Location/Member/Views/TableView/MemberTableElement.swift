//
//  MemberTableElement.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 27.12.2023.
//

import UIKit

enum MemberTableElement {
    case info(MemberInfoElement)
    case title(String)
    case buttons
    case place(MemberPlaceElement)
}

struct MemberInfoElement {
    let photoUrl: URL?
    let name: String
    let batteryLevel: Float?
    let color: UIColor
    
    init(trackInfo: MemberTrackInfo) {
        self.photoUrl = trackInfo.member.photoUrl
        self.name = trackInfo.member.name
        self.batteryLevel = trackInfo.batteryLevel
        
        if trackInfo.member.photoUrl != nil {
            self.color = UIColor.clear
        } else {
            self.color = ColorGenerate.shared.generate(key: trackInfo.member.id)
        }
    }
}

struct MemberPlaceElement {
    let address: String
    let updated: String?
    let withRefresh: Bool
    
    init(address: String, updated: Date?, withRefresh: Bool = false) {
        self.address = address
        
        var updatedLocalizable: String? = nil
        if let date = updated {
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .full
            formatter.locale = Locale(identifier: "en_EN")
            updatedLocalizable = formatter.localizedString(for: date, relativeTo: Date())
        }
        self.updated = updatedLocalizable
        
        self.withRefresh = withRefresh
    }
}
