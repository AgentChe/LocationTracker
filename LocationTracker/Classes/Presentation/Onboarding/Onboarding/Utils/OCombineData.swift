//
//  OCombineData.swift
//  Wicca
//
//  Created by Андрей Чернышев on 23.08.2022.
//

import UIKit

struct OCombineData {
    let pin: String
    let pushToken: String?
}

final class OnboardingCombineData {
    var pin: String?
    var pushToken: String?
    
    func combineData() -> OCombineData? {
        guard let pin = pin else {
            return nil
        }
        
        return OCombineData(
            pin: pin,
            pushToken: pushToken
        )
    }
}

// MARK: OPINViewDelegate
extension OnboardingCombineData: OPINViewDelegate {
    func pinViewDidSet(pin: String) {
        self.pin = pin
    }
}

// MARK: OPermissionsViewDelegate
extension OnboardingCombineData: OPermissionsViewDelegate {
    func permissionsViewDidReceive(pushToken: String?) {
        self.pushToken = pushToken
    }
}
