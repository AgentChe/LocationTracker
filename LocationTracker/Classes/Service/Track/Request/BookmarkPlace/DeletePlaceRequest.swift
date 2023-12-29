//
//  DeletePlaceRequest.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 28.12.2023.
//

import Alamofire

struct DeletePlaceRequest: APIRequestBody {
    let userToken: String
    let placeId: Int

    var url: String {
        GlobalDefinitions.domain + "/api/location/delete_place"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: Parameters? {
        [
            "_api_key": GlobalDefinitions.apiKey,
            "_user_token": userToken,
            "place_id": placeId
        ]
    }
}
