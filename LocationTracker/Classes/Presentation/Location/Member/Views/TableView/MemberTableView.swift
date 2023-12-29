//
//  MemberTableView.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 27.12.2023.
//

import UIKit
import RxSwift
import RxCocoa

final class MemberTableView: UITableView {
    lazy var elements = [MemberTableElement]()
    
    private lazy var didTapChatTrigger = PublishRelay<Void>()
    private lazy var didTapGetDirectionTrigger = PublishRelay<Void>()
    private lazy var didRefreshCurrentPlaceTrigger = PublishRelay<Void>()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension MemberTableView {
    func setup(elements: [MemberTableElement]) {
        self.elements = elements
        
        reloadData()
    }
    
    var didTapChat: Signal<Void> {
        didTapChatTrigger.asSignal()
    }
    
    var didTapGetDirection: Signal<Void> {
        didTapGetDirectionTrigger.asSignal()
    }
    
    var didRefreshCurrentPlace: Signal<Void> {
        didRefreshCurrentPlaceTrigger.asSignal()
    }
}

// MARK: UITableViewDataSource
extension MemberTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch elements[indexPath.row] {
        case .info(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: MemberInfoCell.self), for: indexPath) as! MemberInfoCell
            cell.setup(element: element)
            return cell
        case .title(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: MemberTitleCell.self), for: indexPath) as! MemberTitleCell
            cell.setup(element: element)
            return cell
        case .buttons:
            let cell = dequeueReusableCell(withIdentifier: String(describing: MemberButtonsCell.self), for: indexPath) as! MemberButtonsCell
            cell.didChatTap = { [weak self] in
                self?.didTapChatTrigger.accept(Void())
            }
            cell.didGetDirectionTap = { [weak self] in
                self?.didTapGetDirectionTrigger.accept(Void())
            }
            return cell
        case .place(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: MemberPlaceCell.self), for: indexPath) as! MemberPlaceCell
            cell.setup(element: element)
            cell.didRefresh = { [weak self] in
                self?.didRefreshCurrentPlaceTrigger.accept(Void())
            }
            return cell
        case .preloader:
            let cell = dequeueReusableCell(withIdentifier: String(describing: MemberPreloaderCell.self), for: indexPath) as! MemberPreloaderCell
            cell.preloader.startAnimating()
            return cell
        }
    }
}

// MARK: UITableViewDelegate
extension MemberTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch elements[indexPath.row] {
        case .buttons:
            return 119.scale
        case .preloader:
            return 69.scale
        default:
            return UITableView.automaticDimension
        }
    }
}

// MARK: Private
private extension MemberTableView {
    func initialize() {
        register(MemberInfoCell.self, forCellReuseIdentifier: String(describing: MemberInfoCell.self))
        register(MemberTitleCell.self, forCellReuseIdentifier: String(describing: MemberTitleCell.self))
        register(MemberButtonsCell.self, forCellReuseIdentifier: String(describing: MemberButtonsCell.self))
        register(MemberPlaceCell.self, forCellReuseIdentifier: String(describing: MemberPlaceCell.self))
        register(MemberPreloaderCell.self, forCellReuseIdentifier: String(describing: MemberPreloaderCell.self))
        
        dataSource = self
        delegate = self
    }
}
