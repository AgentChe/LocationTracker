//
//  GeocodeRequest.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 27.12.2023.
//

import Alamofire

struct GeocodeRequest: APIRequestBody {
    let latitude: Double
    let longitude: Double
    
    var url: String {
        "https://api.mapbox.com/geocoding/v5/mapbox.places/\(longitude),\(latitude).json?access_token=\(GlobalDefinitions.mapBoxApiKey)"
    }
}
