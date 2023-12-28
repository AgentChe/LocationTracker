//
//  Place.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 28.12.2023.
//

import Foundation

struct Place: Codable {
    let id: Int
    let location: Location
    let updated: Date
}
