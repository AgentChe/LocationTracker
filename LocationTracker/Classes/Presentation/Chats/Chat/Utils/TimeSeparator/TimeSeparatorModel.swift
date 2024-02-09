//
//  TimeSeparatorModel.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 08.02.2024.
//

import Foundation
import Chatto

final class TimeSeparatorModel: ChatItemProtocol {
    let uid: String
    let type: String = TimeSeparatorModel.chatItemType
    let date: String

    init(uid: String, date: String) {
        self.date = date
        self.uid = uid
    }
    
    static var chatItemType: ChatItemType {
        "TimeSeparatorModel"
    }
}
