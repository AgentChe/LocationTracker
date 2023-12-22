//
//  LocationView.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 21.12.2023.
//

import UIKit
import MapKit

final class LocationView: UIView {
    lazy var mapView = makeMapView()
    lazy var sosButton = makeSOSButton()
    lazy var myCoordinateButton = makeMyCoordinateButton()
    
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
        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: trailingAnchor),
            mapView.topAnchor.constraint(equalTo: topAnchor),
            mapView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            sosButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            sosButton.centerYAnchor.constraint(equalTo: myCoordinateButton.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            myCoordinateButton.widthAnchor.constraint(equalToConstant: 48.scale),
            myCoordinateButton.heightAnchor.constraint(equalToConstant: 48.scale),
            myCoordinateButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            myCoordinateButton.topAnchor.constraint(equalTo: centerYAnchor, constant: 50.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension LocationView {
    func makeMapView() -> LocationMapView {
        let view = LocationMapView()
        view.showsUserLocation = false
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeSOSButton() -> TapAreaButton {
        let attrs = TextAttributes()
            .textColor(Appearance.white)
            .font(Fonts.RobotoCondensed.medium(size: 16.scale))
        
        let view = TapAreaButton()
        view.setAttributedTitle("Location.SOS".localized.attributed(with: attrs), for: .normal)
        view.backgroundColor = Appearance.red
        view.layer.cornerRadius = 20.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeMyCoordinateButton() -> TapAreaButton {
        let view = TapAreaButton()
        view.setImage(UIImage(named: "Location.MyCoordinate"), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
