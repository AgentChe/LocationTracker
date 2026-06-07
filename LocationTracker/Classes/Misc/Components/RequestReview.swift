//
//  RequestReview.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 17.04.2024.
//

import StoreKit

final class RequestReview {
    static func request() {
        DispatchQueue.main.async {
            SKStoreReviewController.requestReview()
        }
    }
}
