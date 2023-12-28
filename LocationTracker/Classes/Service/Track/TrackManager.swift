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
    func geocode(trackInfo: MemberTrackInfo) -> Single<GeocodeResult>
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
    
    func geocode(trackInfo: MemberTrackInfo) -> Single<GeocodeResult> {
        guard let lastLocation = trackInfo.lastPlace?.location else {
            let result = GeocodeResult(trackInfo: trackInfo, address: nil)
            return .just(result)
        }
        
        let request = GeocodeRequest(
            latitude: lastLocation.latitude,
            longitude: lastLocation.longitude
        )
        
        return restAPITransport
            .callServerApi(requestBody: request)
            .map { GeocodeResponse.map(from: $0) }
            .map { GeocodeResult(trackInfo: trackInfo, address: $0) }
    }
}
