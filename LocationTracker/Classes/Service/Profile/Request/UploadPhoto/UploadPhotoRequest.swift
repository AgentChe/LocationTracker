//
//  UploadPhotoRequest.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 21.11.2023.
//

import Alamofire

struct UploadPhotoRequest: APIRequestBody {
    let userToken: String
    
    var url: String {
        GlobalDefinitions.domain + "/api/circle/file?_user_token=\(userToken)&_api_key=\(GlobalDefinitions.apiKey)"
    }
}
