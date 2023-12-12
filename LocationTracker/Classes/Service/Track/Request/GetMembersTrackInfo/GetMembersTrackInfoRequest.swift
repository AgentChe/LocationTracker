//
//  GetMembersTrackInfoRequest.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 11.12.2023.
//

import Alamofire

struct GetMembersTrackInfoRequest: APIRequestBody {
    let userToken: String
    let membersIds: [String]

    var url: String {
        GlobalDefinitions.domain + "/api/location/tracks"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: Parameters? {
        [
            "_api_key": GlobalDefinitions.apiKey,
            "_user_token": userToken,
            "members_ids": membersIds
        ]
    }
}
