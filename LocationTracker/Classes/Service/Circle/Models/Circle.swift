//
//  Circle.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 05.12.2023.
//

import Foundation

struct Circle: Codable {
    let id: String
    let name: String
    let imageUrl: URL?
    let inviteCode: String
    let owner: Member
    let members: [Member]
}
