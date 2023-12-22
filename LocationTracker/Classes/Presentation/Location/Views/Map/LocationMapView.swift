//
//  LocationMapView.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 22.12.2023.
//

import MapKit

final class LocationMapView: MKMapView {
    lazy var meAnnotation = [MeAnnotation]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension LocationMapView {
    func setup(me: MeAnnotation) {
        meAnnotation.forEach { removeAnnotation($0) }
        
        meAnnotation = [me]
        addAnnotation(me)
    }
}

// MARK: MKMapViewDelegate
extension LocationMapView: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? MeAnnotation {
            return mapView.dequeueReusableAnnotationView(withIdentifier: String(describing: MeAnnotationView.self), for: annotation)
        }
        
        return nil
    }
}

// MARK: Private
private extension LocationMapView {
    func initialize() {
        delegate = self
        
        register(MeAnnotationView.self, forAnnotationViewWithReuseIdentifier: String(describing: MeAnnotationView.self))
    }
}
