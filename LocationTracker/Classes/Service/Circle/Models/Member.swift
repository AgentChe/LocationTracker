//
//  Member.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 05.12.2023.
//

import Foundation

struct Member: Codable {
    let id: String
    let name: String
    let photoUrl: URL?
    let roleId: Int?
}
