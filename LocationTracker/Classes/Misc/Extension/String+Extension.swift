//
//  StringExtension.swift
//  Soccer
//
//  Created by Andrey Chernyshev on 16.01.2021.
//

import Foundation

extension String {
    static func choosePluralForm(byNumber: Int, one: String, two: String, many: String) -> String {
        var result = many
        let number = byNumber % 100
        
        if (number < 10 || number >= 20) {
            if (number % 10 == 1) {
                result = one
            }
            if (number % 10 > 1 && number % 10 < 5) {
                result = two
            }
        }
        return result
    }
    
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
    
    func removingWhitespaces() -> String {
        components(separatedBy: .whitespaces).joined()
    }
    
    var utf8_encoded: String? {
        guard let messageData = self.data(using: .nonLossyASCII) else {
            return nil
        }
        
        return String(data: messageData, encoding: .utf8)
    }
    
    var utf8_decoded: String? {
        guard let data = self.data(using: .utf8) else {
            return nil
        }
        
        return String(data: data, encoding: .nonLossyASCII)
    }
}
