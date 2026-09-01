//
//  GlobalDefinitions.swift
//  Soccer
//
//  Created by Andrey Chernyshev on 16.01.2021.
//

import Foundation

final class GlobalDefinitions {
    static let domain = "https://circle.thinkaboutapps.com"
    static let apiKey = "uadq2R32E6OOOkBrxyBH"
    
    static let otterScaleHost = "https://api.korrekted.com"
    static let otterScaleApiKey = "5wOwkcKEe6q4mDQQ"

    static let applicationTag = "LOCATION_TRACKER"
    static let postHogHost = "https://posthog.korrekted.com"
    static let postHogApiKey = "phc_a29Kj3MGr3nLv9NN4WLZiRyHF5mluQZaPbVgcCbIqPa"
    
    static let chatHost = "wss://chat.thinkaboutapps.com:8802"
    static let chatAppKey = "0b783352-1929-4e52-9bcf-d91cd217b2c2"
    
    static let mapBoxApiKey = "pk.eyJ1Ijoic2VyZ2V5a29ycmVrdGVkIiwiYSI6ImNscW5jZmt0dDFieGUycnA5cXVtd2VicXkifQ.NNZjhPY2m7lI4bdi_dSWVw"
    
    static let termsOfServiceUrl = URL(string: "https://thinkaboutapps.com/terms")!
    static let privacyPolicyUrl = URL(string: "https://thinkaboutapps.com/policy")!
    static let contactUsUrl = URL(string: "https://thinkaboutapps.com/contact")!
    
    enum Paygate {
        static let yearly = "app.locationtracker.year"
        static let weekly = "app.locationtracker.week"
    }
}
