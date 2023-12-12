//
//  CirclesTableView.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 06.12.2023.
//

import UIKit
import RxSwift
import RxCocoa

final class CirclesTableView: UITableView {
    lazy var elements = [CirclesTableElement]()
    
    private lazy var didSelectTrigger = PublishRelay<CirclesTableElement>()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension CirclesTableView {
    func setup(elements: [CirclesTableElement]) {
        self.elements = elements
        
        reloadData()
    }
    
    var didSelect: Signal<CirclesTableElement> {
        didSelectTrigger.asSignal()
    }
}

// MARK: UITableViewDataSource
extension CirclesTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dequeueReusableCell(withIdentifier: String(describing: CirclesTableCell.self)) as! CirclesTableCell
        cell.setup(element: elements[indexPath.row])
        return cell
    }
}

// MARK: UITableViewDelegate
extension CirclesTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let element = elements[indexPath.row]
        didSelectTrigger.accept(element)
    }
}

// MARK: Private
private extension CirclesTableView {
    func initialize() {
        register(CirclesTableCell.self, forCellReuseIdentifier: String(describing: CirclesTableCell.self))
        
        dataSource = self
        delegate = self
    }
}
