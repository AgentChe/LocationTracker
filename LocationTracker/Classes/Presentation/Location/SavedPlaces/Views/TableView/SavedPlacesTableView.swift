//
//  SavedPlacesTableView.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 11.01.2024.
//

import UIKit
import RxSwift
import RxCocoa

final class SavedPlacesTableView: UITableView {
    lazy var elements = [GeocodeResult]()
    
    private lazy var didSelectTrigger = PublishRelay<GeocodeResult>()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension SavedPlacesTableView {
    func setup(elements: [GeocodeResult]) {
        self.elements = elements
        
        reloadData()
    }
    
    var didSelect: Signal<GeocodeResult> {
        didSelectTrigger.asSignal()
    }
}

// MARK: UITableViewDataSource
extension SavedPlacesTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dequeueReusableCell(withIdentifier: String(describing: SavedPlacesTableCell.self), for: indexPath) as! SavedPlacesTableCell
        cell.setup(element: elements[indexPath.row])
        return cell
    }
}

// MARK: UITableViewDelegate
extension SavedPlacesTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectTrigger.accept(elements[indexPath.row])
    }
}

// MARK: Private
private extension SavedPlacesTableView {
    func initialize() {
        register(SavedPlacesTableCell.self, forCellReuseIdentifier: String(describing: SavedPlacesTableCell.self))
        
        dataSource = self
        delegate = self
    }
}
