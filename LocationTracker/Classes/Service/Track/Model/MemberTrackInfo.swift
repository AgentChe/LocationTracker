//
//  MemberTrackInfo.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 11.12.2023.
//

import UIKit
import Foundation

struct MemberTrackInfo: Codable {
    let member: Member
    let lastPlace: Place?
    let batteryLevel: Int?
}
