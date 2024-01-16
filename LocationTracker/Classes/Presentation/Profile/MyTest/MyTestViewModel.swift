//
//  MyTestViewModel.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 12.01.2024.
//

import RxSwift
import RxCocoa
import Alamofire

struct MyTestRequest: APIRequestBody {
    let userToken: String

    var url: String {
        GlobalDefinitions.domain + "/api/location/list_geo"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: Parameters? {
        [
            "_api_key": GlobalDefinitions.apiKey,
            "_user_token": userToken
        ]
    }
}

final class MyTestViewModel {
    private lazy var activity = RxActivityIndicator()
    
    private lazy var restAPITransport = RestAPITransport()
    
    private lazy var trackManager = TrackManager()
    private lazy var sessionManager = SessionManager()
}

// MARK: Public
extension MyTestViewModel {
    struct Input {}
    
    struct Output {
        let elements: Driver<[GeocodeResult]>
        let activity: Driver<Bool>
    }
    
    func configure(input: Input) -> Output {
        let response = makeResponse()
        let places = makePlaces(response: response)
        let geocode = makeGeocode(places: places)
        
        return Output(
            elements: geocode,
            activity: activity.asDriver()
        )
    }
}

// MARK: Private
private extension MyTestViewModel {
    func makeGeocode(places: Driver<[Place]>) -> Driver<[GeocodeResult]> {
        places
            .flatMapLatest { [weak self] places -> Driver<[GeocodeResult]> in
                guard let self else {
                    return .never()
                }
                
                let geocode = places.map {
                    self.trackManager.geocode(place: $0)
                }
                
                return Single
                    .zip(geocode)
                    .trackActivity(self.activity)
                    .asDriver(onErrorJustReturn: [])
            }
    }
    
    func makePlaces(response: Driver<Any>) -> Driver<[Place]> {
        response
            .map { response -> [Place] in
                guard
                    let json = response as? [String: Any],
                    let data = json["_data"] as? [[String: Any]]
                else {
                    return []
                }
                
                let formatter = DateFormatter()
                formatter.dateFormat = "dd.MM.yyyy HH:mm"
                
                return data.compactMap { json -> Place? in
                    guard
                        let latitude = json["latitude"] as? Double,
                        let longitude = json["longitude"] as? Double,
                        let dateString = json["date"] as? String,
                        let date = formatter.date(from: dateString)
                    else {
                        return nil
                    }
                    
                    let location = Location(
                        latitude: latitude,
                        longitude: longitude
                    )
                    
                    return Place(
                        id: Int.random(in: Int.min...Int.max),
                        location: location,
                        updated: date
                    )
                }
            }
    }
    
    func makeResponse() -> Driver<Any> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .never()
        }
        
        let request = MyTestRequest(userToken: userToken)
        
        return restAPITransport
            .callServerApi(requestBody: request)
            .asDriver(onErrorDriveWith: .never())
    }
}
