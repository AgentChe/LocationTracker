//
//  GeocodeResult.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 25.12.2023.
//

struct GeocodeResult: Codable {
    let place: Place
    let address: String?
}
