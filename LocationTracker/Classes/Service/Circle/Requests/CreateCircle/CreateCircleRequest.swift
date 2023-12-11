//
//  CreateCircleRequest.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 05.12.2023.
//

import Alamofire

struct CreateCircleRequest: APIRequestBody {
    let userToken: String
    let photoPath: String?
    let name: String
    let roleId: Int

    var url: String {
        GlobalDefinitions.domain + "/api/circle/create"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: Parameters? {
        var params = [
            "_api_key": GlobalDefinitions.apiKey,
            "_user_token": userToken,
            "name": name,
            "role_id": roleId
        ] as [String : Any]
        
        if let photoPath {
            params["image"] = photoPath
        }
        
        return params
    }
}
