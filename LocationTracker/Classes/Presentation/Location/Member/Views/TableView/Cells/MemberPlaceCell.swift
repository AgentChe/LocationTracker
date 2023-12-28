//
//  MemberPlaceCell.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 28.12.2023.
//

import UIKit

final class MemberPlaceCell: UITableViewCell {
    var didRefresh: (() -> Void)? 
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension MemberPlaceCell {
    func setup(element: MemberPlaceElement) {
        
    }
}

// MARK: Private
private extension MemberPlaceCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension MemberPlaceCell {
    func makeConstraints() {
        
    }
}

// MARK: Lazy initialization
private extension MemberPlaceCell {
    
}
