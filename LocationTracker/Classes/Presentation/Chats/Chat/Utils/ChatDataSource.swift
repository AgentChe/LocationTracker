//
//  ChatDataSource.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 09.02.2024.
//

import Chatto
import ChattoAdditions

final class ChatDataSource {
    weak var delegate: Chatto.ChatDataSourceDelegateProtocol?
}

// MARK: ChatDataSourceProtocol
extension ChatDataSource: ChatDataSourceProtocol {
    var hasMoreNext: Bool {
        false
    }
    
    var hasMorePrevious: Bool {
        false
    }
    
    var chatItems: [Chatto.ChatItemProtocol] {
        []
    }
    
    func loadNext() {
        
    }
    
    func loadPrevious() {
        
    }
    
    func adjustNumberOfMessages(preferredMaxCount: Int?, focusPosition: Double, completion: (Bool) -> Void) {
        completion(false)
    }
}
