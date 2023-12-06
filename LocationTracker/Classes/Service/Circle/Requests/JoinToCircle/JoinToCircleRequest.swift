//
//  JoinToCircleRequest.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 05.12.2023.
//

import Alamofire

struct JoinToCircleRequest: APIRequestBody {
    let userToken: String
    let inviteCode: String

    var url: String {
        GlobalDefinitions.domain + "/api/circle/join"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: Parameters? {
        [
            "_api_key": GlobalDefinitions.apiKey,
            "_user_token": userToken,
            "invite_code": inviteCode
        ]
    }
}
