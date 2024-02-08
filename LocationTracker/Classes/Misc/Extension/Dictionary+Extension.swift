//
//  Dictionary+Extension.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 07.02.2024.
//

import Foundation

// MARK: Additional
extension Dictionary {
    func jsonString() -> String? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: [])
            return String(data: jsonData, encoding: .ascii)
        } catch {
            return nil
        }
    }
}

