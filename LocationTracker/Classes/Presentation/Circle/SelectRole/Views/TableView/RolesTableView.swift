//
//  RolesTableView.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 07.12.2023.
//

import UIKit
import RxSwift
import RxCocoa

final class RolesTableView: UITableView {
    lazy var elements = [RolesTableElement]()
    
    private lazy var didSelectTrigger = PublishRelay<RolesTableElement>()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension RolesTableView {
    func setup(elements: [RolesTableElement]) {
        self.elements = elements
        
        reloadData()
    }
    
    var didSelect: Signal<RolesTableElement> {
        didSelectTrigger.asSignal()
    }
}

// MARK: UITableViewDataSource
extension RolesTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dequeueReusableCell(withIdentifier: String(describing: RolesTableCell.self)) as! RolesTableCell
        cell.setup(element: elements[indexPath.row])
        return cell
    }
}

// MARK: UITableViewDelegate
extension RolesTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectTrigger.accept(elements[indexPath.row])
    }
}

// MARK: Private
private extension RolesTableView {
    func initialize() {
        register(RolesTableCell.self, forCellReuseIdentifier: String(describing: RolesTableCell.self))
        
        dataSource = self
        delegate = self
    }
}
