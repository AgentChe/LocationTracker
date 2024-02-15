//
//  SaveGeoRequest.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 11.01.2024.
//

import Alamofire

struct SaveGeoRequest: APIRequestBody {
    let userToken: String
    let latitude: Double
    let longitude: Double
    let batteryLevel: Int

    var url: String {
        GlobalDefinitions.domain + "/api/location/save_geo"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: Parameters? {
        [
            "_api_key": GlobalDefinitions.apiKey,
            "_user_token": userToken,
            "latitude": latitude,
            "longitude": longitude,
            "battery_level": batteryLevel
        ]
    }
}
