//
//  TrackManager.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 11.12.2023.
//

import RxSwift
import CoreLocation
import Contacts

protocol TrackManagerProtocol {
    func obtainTrackInfo(for membersIds: [String]) -> Single<[MemberTrackInfo]>
    func geocode(place: Place) -> Single<GeocodeResult>
    func places(for memberId: String, date: String) -> Single<[Place]>
    func save(placeId: Int) -> Single<Void>
    func delete(placeId: Int) -> Single<Void>
    func savedPlaces() -> Single<[Place]>
}

final class TrackManager {
    private lazy var sessionManager = SessionManager()
    
    private lazy var restAPITransport = RestAPITransport()
    private lazy var defaultRequestWrapper = DefaultRequestWrapper()
}

// MARK: TrackManagerProtocol
extension TrackManager: TrackManagerProtocol {
    func obtainTrackInfo(for membersIds: [String]) -> Single<[MemberTrackInfo]> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }

        let request = GetMembersTrackInfoRequest(
            userToken: userToken,
            membersIds: membersIds
        )

        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .map { GetMembersTrackInfoResponse.map(from: $0) }
    }
    
    func geocode(place: Place) -> Single<GeocodeResult> {
        let request = GeocodeRequest(
            latitude: place.location.latitude,
            longitude: place.location.longitude
        )
        
        return restAPITransport
            .callServerApi(requestBody: request)
            .map { GeocodeResponse.map(from: $0) }
            .map { GeocodeResult(place: place, address: $0) }
    }
    
    func places(for memberId: String, date: String) -> Single<[Place]> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }
        
        let request = GetPlacesOnDayRequest(
            userToken: userToken,
            memberId: memberId,
            date: date
        )
        
        return restAPITransport
            .callServerApi(requestBody: request)
            .map { GetPlacesOnDayResponse.map(from: $0) }
    }
    
    func save(placeId: Int) -> Single<Void> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }
        
        let request = AddPlaceRequest(
            userToken: userToken,
            placeId: placeId
        )
        
        return restAPITransport
            .callServerApi(requestBody: request)
            .mapToVoid()
            .do(onSuccess: {
                TrackMediator.shared.save(placeId: placeId)
            })
    }
    
    func delete(placeId: Int) -> Single<Void> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }
        
        let request = DeletePlaceRequest(
            userToken: userToken,
            placeId: placeId
        )
        
        return restAPITransport
            .callServerApi(requestBody: request)
            .mapToVoid()
            .do(onSuccess: {
                TrackMediator.shared.delete(placeId: placeId)
            })
    }
    
    func savedPlaces() -> Single<[Place]> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }
        
        let request = SavedPlacesRequest(userToken: userToken)
        
        return restAPITransport
            .callServerApi(requestBody: request)
            .map { SavedPlacesResponse.map(from: $0) }
    }
}
