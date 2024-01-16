//
//  SendSOSRequest.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 16.01.2024.
//

import Alamofire

struct SendSOSRequest: APIRequestBody {
    let userToken: String
    let circleId: Int

    var url: String {
        GlobalDefinitions.domain + "/api/circle/send_sos"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: Parameters? {
        [
            "_api_key": GlobalDefinitions.apiKey,
            "_user_token": userToken,
            "circle_id": circleId
        ]
    }
}
