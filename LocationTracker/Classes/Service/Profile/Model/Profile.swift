//
//  Profile.swift
//  Soccer
//
//  Created by Андрей Чернышев on 03.02.2023.
//

import Foundation

struct Profile: Codable, Hashable {
    let name: String
    let photoUrl: URL?
    let pin: String?
}
