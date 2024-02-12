//
//  SessionManagerCore.swift
//  Soccer
//
//  Created by Andrey Chernyshev on 17.01.2021.
//

import RxCocoa
import OtterScaleiOS

protocol SessionManagerProtocol {
    func store(session: Session)
    func getSession() -> Session?
    func hasActiveSubscriptions() -> Bool
}

final class SessionManager: SessionManagerProtocol {
    struct Constants {
        static let sessionCacheKey = "session_manage_session_cache_key"
    }
}

// MARK: API
extension SessionManager {
    func store(session: Session) {
        guard let data = try? JSONEncoder().encode(session) else {
            return
        }
        
        UserDefaults.standard.setValue(data, forKey: Constants.sessionCacheKey)
    }
    
    func getSession() -> Session? {
        guard
            let data = UserDefaults.standard.data(forKey: Constants.sessionCacheKey),
            let session = try? JSONDecoder().decode(Session.self, from: data)
        else {
            return nil
        }

        return session
    }
    
    // TODO
    var userId: String {
//        "f70b4caf-677c-44d6-a349-cc7ca8279e36" // iPhone 14 pro, me
        "64f06464-2284-4a6a-b5f7-9c8356238259" // iPhone 8, partner
//        OtterScale.shared.getInternalID()
    }
    
    func hasActiveSubscriptions() -> Bool {
        guard let paymentData = OtterScale.shared.getPaymentData() else {
            return false
        }
        
        let subscriptions = paymentData.subscriptions.appleAppStore
            + paymentData.subscriptions.googlePlay
            + paymentData.subscriptions.stripe
            + paymentData.subscriptions.paypal
        let nonConsumables = paymentData.nonConsumables.appleAppStore
            + paymentData.nonConsumables.googlePlay
            + paymentData.nonConsumables.stripe
            + paymentData.nonConsumables.paypal

        let hasValidSubscription = subscriptions.contains(where: { $0.valid })
        let hasValidNonConsumable = nonConsumables.contains(where: { $0.valid })

        return hasValidSubscription || hasValidNonConsumable
    }
}
