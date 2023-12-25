//
//  LocationCircleTableView.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 25.12.2023.
//

import UIKit
import RxSwift
import RxCocoa

final class LocationCircleTableView: UITableView {
    lazy var elements = [LocationCircleTableElement]()
    
    private lazy var didSelectTrigger = PublishRelay<LocationCircleTableElement>()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension LocationCircleTableView {
    func setup(elements: [LocationCircleTableElement]) {
        self.elements = elements
        
        reloadData()
    }
    
    var didSelect: Signal<LocationCircleTableElement> {
        didSelectTrigger.asSignal()
    }
}

// MARK: UITableViewDataSource
extension LocationCircleTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch elements[indexPath.row] {
        case .circleName(let name):
            let cell = dequeueReusableCell(withIdentifier: String(describing: LocationCircleNameCell.self), for: indexPath) as! LocationCircleNameCell
            cell.setup(name: name)
            return cell
        case .title:
            return dequeueReusableCell(withIdentifier: String(describing: DetailsCircleTitleCell.self), for: indexPath)
        case .member(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: DetailsCircleMemberCell.self), for: indexPath) as! DetailsCircleMemberCell
            cell.setup(element: element)
            return cell
        case .action(let action):
            let cell = dequeueReusableCell(withIdentifier: String(describing: DetailsCircleActionCell.self), for: indexPath) as! DetailsCircleActionCell
            cell.setup(action: action)
            return cell
        case .create:
            return dequeueReusableCell(withIdentifier: String(describing: LocationCircleCreateCell.self), for: indexPath)
        }
    }
}

// MARK: UITableViewDelegate
extension LocationCircleTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let element = elements[indexPath.row]
        didSelectTrigger.accept(element)
    }
}

// MARK: Private
private extension LocationCircleTableView {
    func initialize() {
        register(LocationCircleNameCell.self, forCellReuseIdentifier: String(describing: LocationCircleNameCell.self))
        register(DetailsCircleTitleCell.self, forCellReuseIdentifier: String(describing: DetailsCircleTitleCell.self))
        register(DetailsCircleMemberCell.self, forCellReuseIdentifier: String(describing: DetailsCircleMemberCell.self))
        register(DetailsCircleActionCell.self, forCellReuseIdentifier: String(describing: DetailsCircleActionCell.self))
        register(LocationCircleCreateCell.self, forCellReuseIdentifier: String(describing: LocationCircleCreateCell.self))
        
        dataSource = self
        delegate = self
    }
}
