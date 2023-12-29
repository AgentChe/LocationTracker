//
//  SavedPlacesRequest.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 28.12.2023.
//

import Alamofire

struct SavedPlacesRequest: APIRequestBody {
    let userToken: String

    var url: String {
        GlobalDefinitions.domain + "/api/location/saved_places"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: Parameters? {
        [
            "_api_key": GlobalDefinitions.apiKey,
            "_user_token": userToken
        ]
    }
}
