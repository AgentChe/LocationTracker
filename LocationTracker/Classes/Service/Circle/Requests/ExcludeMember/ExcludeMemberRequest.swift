//
//  ExcludeMemberRequest.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 05.12.2023.
//

import Alamofire

struct ExcludeMemberRequest: APIRequestBody {
    let userToken: String
    let memberId: String
    let circleId: String

    var url: String {
        GlobalDefinitions.domain + "/api/circle/exclude"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: Parameters? {
        [
            "_api_key": GlobalDefinitions.apiKey,
            "_user_token": userToken,
            "member_id": memberId,
            "circle_id": circleId
        ]
    }
}
