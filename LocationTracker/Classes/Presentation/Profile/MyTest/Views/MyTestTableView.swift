//
//  MyTestTableView.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 12.01.2024.
//

import UIKit

final class MyTestTableView: UITableView {
    lazy var elements = [GeocodeResult]()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension MyTestTableView {
    func setup(elements: [GeocodeResult]) {
        self.elements = elements
        
        reloadData()
    }
}

// MARK: UITableViewDataSource
extension MyTestTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dequeueReusableCell(withIdentifier: String(describing: MyTestTableCell.self)) as! MyTestTableCell
        cell.setup(element: elements[indexPath.row])
        return cell
    }
}

// MARK: UITableViewDelegate
extension MyTestTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}

// MARK: Private
private extension MyTestTableView {
    func initialize() {
        register(MyTestTableCell.self, forCellReuseIdentifier: String(describing: MyTestTableCell.self))
        
        dataSource = self
        delegate = self
    }
}
