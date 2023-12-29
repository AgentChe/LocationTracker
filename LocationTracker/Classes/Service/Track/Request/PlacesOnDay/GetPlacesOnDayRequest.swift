//
//  GetPlacesOnDayRequest.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 28.12.2023.
//

import Alamofire

struct GetPlacesOnDayRequest: APIRequestBody {
    let userToken: String
    let memberId: String
    let date: String

    var url: String {
        GlobalDefinitions.domain + "/api/location/history"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: Parameters? {
        [
            "_api_key": GlobalDefinitions.apiKey,
            "_user_token": userToken,
            "member_id": memberId,
            "date": date
        ]
    }
}
