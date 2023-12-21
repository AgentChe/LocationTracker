//
//  LocationView.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 21.12.2023.
//

import UIKit

final class LocationView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension LocationView {
    func initialize() {
        backgroundColor = Appearance.background1
    }
}

// MARK: Make constraints
private extension LocationView {
    func makeConstraints() {
        
    }
}

// MARK: Lazy initialization
private extension LocationView {
    
}
