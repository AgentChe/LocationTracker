//
//  Language.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 30.05.2024.
//

import UIKit

enum Language {
    case en, pt, ptBr, de, ru, fr
    
    init(code: String = UIDevice.deviceLanguageCode ?? "") {
        switch code {
        case "en":
            self = .en
        case "pt":
            self = .pt
        case "pt-BR":
            self = .ptBr
        case "de":
            self = .de
        case "ru":
            self = .ru
        case "fr":
            self = .fr
        default:
            self = .en
        }
    }
}
