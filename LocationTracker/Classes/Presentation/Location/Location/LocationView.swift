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
    lazy var circleView = makeCircleView()
    
    private lazy var circleViewHeightConstraint = NSLayoutConstraint()
    
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
    
    @objc
    func swipeUpLocationView() {
        changeCircleView(height: frame.height - 100.scale)
    }
    
    @objc
    func swipeDownLocationView() {
        changeCircleView(height: 300.scale)
    }
    
    func changeCircleView(height: CGFloat) {
        circleViewHeightConstraint.isActive = false
        circleViewHeightConstraint.constant = height
        circleViewHeightConstraint.isActive = true
        
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.layoutIfNeeded()
        })
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
            myCoordinateButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -316.scale)
        ])
        
        circleViewHeightConstraint = circleView.heightAnchor.constraint(equalToConstant: 300.scale)
        NSLayoutConstraint.activate([
            circleView.leadingAnchor.constraint(equalTo: leadingAnchor),
            circleView.trailingAnchor.constraint(equalTo: trailingAnchor),
            circleView.bottomAnchor.constraint(equalTo: bottomAnchor),
            circleViewHeightConstraint
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
    
    func makeSOSButton() -> SOSButton {
        let view = SOSButton()
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
    
    func makeCircleView() -> LocationCircleView {
        let swipeUpGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeUpLocationView))
        swipeUpGesture.direction = .up
        
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeDownLocationView))
        swipeDownGesture.direction = .down
        
        let view = LocationCircleView()
        view.swipeArea.isUserInteractionEnabled = true
        view.swipeArea.addGestureRecognizer(swipeUpGesture)
        view.swipeArea.addGestureRecognizer(swipeDownGesture)
        view.backgroundColor = Appearance.background1
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
