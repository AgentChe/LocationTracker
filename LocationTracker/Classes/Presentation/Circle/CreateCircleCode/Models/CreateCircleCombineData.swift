//
//  CreateCircleCombineData.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 08.12.2023.
//

import UIKit

struct CreateCircleCombineData {
    var name: String
    var image: UIImage?
    var roleId: Int?
    
    init(
        name: String,
        image: UIImage? = nil,
        roleId: Int? = nil
    ) {
        self.name = name
        self.image = image
        self.roleId = roleId
    }
    
    func name(_ name: String) -> CreateCircleCombineData {
        var copy = self
        copy.name = name
        return copy
    }
    
    func image(_ image: UIImage?) -> CreateCircleCombineData {
        var copy = self
        copy.image = image
        return copy
    }
    
    func roleId(_ roleId: Int?) -> CreateCircleCombineData {
        var copy = self
        copy.roleId = roleId
        return copy
    }
}
