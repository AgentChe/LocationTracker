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
    func geocode(trackInfo: MemberTrackInfo) -> Single<(MemberTrackInfo, String?)>
}

final class TrackManager {
    private lazy var sessionManager = SessionManager()
    
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
    
    func geocode(trackInfo: MemberTrackInfo) -> Single<(MemberTrackInfo, String?)> {
        Single<(MemberTrackInfo, String?)>.create { single in
            guard let location = trackInfo.lastLocation else {
                single(.success((trackInfo, nil)))
                return Disposables.create()
            }
            
            let geocoder = CLGeocoder()
            
            let coordinate = CLLocation(
                latitude: location.latitude,
                longitude: location.longitude
            )
            let locale = Locale(identifier: "en_EN")
            
            geocoder.reverseGeocodeLocation(coordinate, preferredLocale: locale) { result, error in
                var address: String? {
                    guard let postalAddress = result?.first?.postalAddress else {
                        return nil
                    }
                    
                    let formatter = CNPostalAddressFormatter()
                    formatter.style = .mailingAddress
                    
                    return formatter.string(from: postalAddress)
                }
                
                single(.success((trackInfo, address)))
            }
            
            return Disposables.create {
                geocoder.cancelGeocode()
            }
        }
    }
}
