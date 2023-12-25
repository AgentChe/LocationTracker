//
//  LocationMapView.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 22.12.2023.
//

import MapKit

final class LocationMapView: MKMapView {
    lazy var membersAnnotations = [MemberAnnotation]()
    
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
    func setup(membersAnnotations: [MemberAnnotation]) {
        self.membersAnnotations.forEach { removeAnnotation($0) }
        
        self.membersAnnotations = membersAnnotations
        self.membersAnnotations.forEach { addAnnotation($0) }
    }
}

// MARK: MKMapViewDelegate
extension LocationMapView: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? MemberAnnotation else {
            return nil
        }
        
        let key = String(describing: annotation.me ? MeAnnotationView.self : MemberAnnotationView.self)
        return mapView.dequeueReusableAnnotationView(withIdentifier: key, for: annotation)
    }
}

// MARK: Private
private extension LocationMapView {
    func initialize() {
        delegate = self
        
        register(MeAnnotationView.self, forAnnotationViewWithReuseIdentifier: String(describing: MeAnnotationView.self))
        register(MemberAnnotationView.self, forAnnotationViewWithReuseIdentifier: String(describing: MemberAnnotationView.self))
    }
}
