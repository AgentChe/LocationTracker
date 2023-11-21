//
//  UploadPhotoResponse.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 21.11.2023.
//

import Foundation

enum UploadPhotoResponse {
    static func map(from response: Any) -> URL? {
        guard
            let json = response as? [String: Any],
            let data = json["_data"] as? [String: Any],
            let path = data["url"] as? String,
            let url = URL(string: path)
        else {
            return nil
        }
        
        return url
    }
}
