//
//  DetailsCircleTableView.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 11.12.2023.
//

import UIKit
import RxSwift
import RxCocoa

final class DetailsCircleTableView: UITableView {
    lazy var elements = [DetailsCircleTableElement]()
    
    private lazy var didSelectTrigger = PublishRelay<DetailsCircleTableElement>()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension DetailsCircleTableView {
    func setup(elements: [DetailsCircleTableElement]) {
        self.elements = elements
        
        reloadData()
    }
    
    var didSelect: Signal<DetailsCircleTableElement> {
        didSelectTrigger.asSignal()
    }
}

// MARK: UITableViewDataSource
extension DetailsCircleTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch elements[indexPath.row] {
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
        }
    }
}

// MARK: UITableViewDelegate
extension DetailsCircleTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let element = elements[indexPath.row]
        didSelectTrigger.accept(element)
    }
}

// MARK: Private
private extension DetailsCircleTableView {
    func initialize() {
        register(DetailsCircleTitleCell.self, forCellReuseIdentifier: String(describing: DetailsCircleTitleCell.self))
        register(DetailsCircleMemberCell.self, forCellReuseIdentifier: String(describing: DetailsCircleMemberCell.self))
        register(DetailsCircleActionCell.self, forCellReuseIdentifier: String(describing: DetailsCircleActionCell.self))
        
        dataSource = self
        delegate = self
    }
}
