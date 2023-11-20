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
}

final class OnboardingCombineData {
    var name: String?
    var photo: UIImage?
    
    func combineData() -> OCombineData? {
        guard let name = name else { return nil }
        
        return OCombineData(
            name: name,
            photo: photo
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
