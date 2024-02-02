//
//  ChatsTableView.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 02.02.2024.
//

import UIKit
import RxSwift
import RxCocoa

final class ChatsTableView: UITableView {
    lazy var elements = [ChatsTableElement]()
    
    private lazy var didTapMenuTrigger = PublishRelay<Chat>()
    private lazy var didSelectChatTrigger = PublishRelay<Chat>()
    private lazy var didChangeElementsCountTrigger = PublishRelay<Int>()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension ChatsTableView {
    func setup(elements: [ChatsTableElement]) {
        self.elements = elements
        
        sortElements()
        
        reloadData()
        
        didChangeElementsCountTrigger.accept(elements.count)
    }
    
    func changed(element: ChatsTableElement) {
        guard let index = elements.firstIndex(where: { $0.chat.id == element.chat.id }) else {
            return
        }
        
        elements[index] = element
        
        sortElements()
        
        let indexPaths = elements.enumerated().map { index, _ -> IndexPath in
            IndexPath(row: index, section: 0)
        }
        reloadRows(at: indexPaths, with: .automatic)
    }
    
    func created(element: ChatsTableElement) {
        elements.append(element)
        
        sortElements()
        
        guard let index = elements.firstIndex(where: { $0.chat.id == element.chat.id }) else {
            return
        }
        
        let indexPath = IndexPath(row: index, section: 0)
        insertRows(at: [indexPath], with: .automatic)
        
        didChangeElementsCountTrigger.accept(elements.count)
    }
    
    func removed(id: String) {
        guard let index = elements.firstIndex(where: { $0.chat.id == id }) else {
            return
        }
        
        elements.remove(at: index)
        
        let indexPath = IndexPath(row: index, section: 0)
        deleteRows(at: [indexPath], with: .automatic)
        
        didChangeElementsCountTrigger.accept(elements.count)
    }
    
    var didTapMenu: Signal<Chat> {
        didTapMenuTrigger.asSignal()
    }
    
    var didSelectChat: Signal<Chat> {
        didSelectChatTrigger.asSignal()
    }
    
    var didChangeElementsCount: Signal<Int> {
        didChangeElementsCountTrigger.asSignal()
    }
}

// MARK: UITableViewDataSource
extension ChatsTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let element = elements[indexPath.row]
        let cell = dequeueReusableCell(withIdentifier: String(describing: ChatsTableCell.self), for: indexPath) as! ChatsTableCell
        cell.setup(element: element)
        cell.didTapMenu = { [weak self] in
            self?.didTapMenuTrigger.accept(element.chat)
        }
        return cell
    }
}

// MARK: UITableViewDelegate
extension ChatsTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        92.scale
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectChatTrigger.accept(elements[indexPath.row].chat)
    }
}

// MARK: Private
private extension ChatsTableView {
    func initialize() {
        register(ChatsTableCell.self, forCellReuseIdentifier: String(describing: ChatsTableCell.self))
        
        dataSource = self
        delegate = self
    }
    
    func sortElements() {
        elements.sort { lhs, rhs -> Bool in
            let lhsCreated = lhs.chat.lastMessage?.created ?? 0
            let rhsCreated = rhs.chat.lastMessage?.created ?? 0
            return lhsCreated > rhsCreated
        }
    }
}
