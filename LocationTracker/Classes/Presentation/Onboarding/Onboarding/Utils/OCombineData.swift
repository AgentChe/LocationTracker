//
//  OCombineData.swift
//  Wicca
//
//  Created by Андрей Чернышев on 23.08.2022.
//

import Foundation

struct OCombineData {
    let name: String
}

final class OnboardingCombineData {
    var name: String?
    
    func combineData() -> OCombineData? {
        guard
            let name = name
        else {
            return nil
        }
        
        return OCombineData(
            name: name
        )
    }
}

// MARK: ONameViewDelegate
extension OnboardingCombineData: ONameViewDelegate {
    func nameViewDidEnter(name: String) {
        self.name = name
    }
}
