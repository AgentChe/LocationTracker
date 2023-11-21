//
//  OCombineData.swift
//  Wicca
//
//  Created by Андрей Чернышев on 23.08.2022.
//

import UIKit

struct OCombineData {
    let name: String
    let photo: UIImage?
    let pin: String
    let pushToken: String?
}

final class OnboardingCombineData {
    var name: String?
    var photo: UIImage?
    var pin: String?
    var pushToken: String?
    
    func combineData() -> OCombineData? {
        guard
            let name = name,
            let pin = pin
        else {
            return nil
        }
        
        return OCombineData(
            name: name,
            photo: photo,
            pin: pin,
            pushToken: pushToken
        )
    }
}

// MARK: ONameViewDelegate
extension OnboardingCombineData: ONameViewDelegate {
    func nameViewDidEnter(name: String) {
        self.name = name
    }
}

// MARK: OPhotoViewDelegate
extension OnboardingCombineData: OPhotoViewDelegate {
    func photoViewDidSelect(image: UIImage) {
        self.photo = image
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
