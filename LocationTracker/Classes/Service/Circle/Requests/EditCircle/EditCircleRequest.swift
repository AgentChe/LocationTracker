//
//  EditCircleRequest.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 05.12.2023.
//

import Alamofire

struct EditCircleRequest: APIRequestBody {
    let userToken: String
    let id: String
    let photoPath: String?
    let name: String
    let roleId: String

    var url: String {
        GlobalDefinitions.domain + "/api/circle/edit"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: Parameters? {
        var params = [
            "_api_key": GlobalDefinitions.apiKey,
            "_user_token": userToken,
            "id": id,
            "name": name,
            "role_id": roleId
        ]
        
        if let photoPath {
            params["image"] = photoPath
        }
        
        return params
    }
}
