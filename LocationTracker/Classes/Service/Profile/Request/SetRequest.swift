//
//  SetRequest.swift
//  Soccer
//
//  Created by Андрей Чернышев on 28.08.2022.
//

import Alamofire

struct SetRequest: APIRequestBody {
    let userToken: String
    let name: String
    let photoPath: String?
    let pin: String?
    let pushToken: String?
    
    var url: String {
        GlobalDefinitions.domain + "/api/users/set"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: Parameters? {
        var params: [String: Any] = [
            "_api_key": GlobalDefinitions.apiKey,
            "_user_token": userToken,
            "name": name
        ]
        
        if let photoPath {
            params["photo"] = photoPath
        }
        
        if let pin {
            params["pin"] = pin
        }
        
        if let pushToken {
            params["push_token"] = pushToken
        }
        
        return params
    }
}
