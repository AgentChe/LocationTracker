//
//  DeleteCircleRequest.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 05.12.2023.
//

import Alamofire

struct DeleteCircleRequest: APIRequestBody {
    let userToken: String
    let id: String

    var url: String {
        GlobalDefinitions.domain + "/api/circle/delete"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: Parameters? {
        [
            "_api_key": GlobalDefinitions.apiKey,
            "_user_token": userToken,
            "id": id
        ]
    }
}
