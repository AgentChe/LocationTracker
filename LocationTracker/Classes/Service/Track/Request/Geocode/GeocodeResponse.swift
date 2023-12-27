//
//  GeocodeResponse.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 27.12.2023.
//

enum GeocodeResponse {
    static func map(from result: Any) -> String? {
        guard
            let json = result as? [String: Any],
            let featuresArray = json["features"] as? [[String: Any]]
        else {
            return nil
        }
        
        let features = featuresArray.compactMap { featureJSON -> Feature? in
            guard
                let placeTypes = featureJSON["place_type"] as? [String],
                let placeName = featureJSON["place_name"] as? String,
                !placeName.isEmpty
            else {
                return nil
            }
            
            return Feature(
                placeTypes: placeTypes,
                placeName: placeName
            )
        }
        
        let feature = features.first(where: { feature -> Bool in
            feature.placeTypes.contains("address")
        })?.placeName
        
        let result = feature ?? features.first?.placeName
        
        return result
    }
}

private struct Feature {
    let placeTypes: [String]
    let placeName: String
}
