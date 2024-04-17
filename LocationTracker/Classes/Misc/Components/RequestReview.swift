//
//  RequestReview.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 17.04.2024.
//

import StoreKit

final class RequestReview {
    static func request() {
        AmplitudeManager.shared
            .logEvent(name: "Rating Request")
        
        DispatchQueue.main.async {
            SKStoreReviewController.requestReview()
        }
    }
}
