//
//  ChatDataSource.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 09.02.2024.
//

import Chatto
import ChattoAdditions

final class ChatDataSource {
    enum Constants {
        static let preferredMaxWindowSize = 500
    }
    
    enum InsertPosition {
        case top
        case bottom
    }
    
    var didLoadNextPage: ((Int) -> Void)?
    
    weak var delegate: Chatto.ChatDataSourceDelegateProtocol?
    
    private var lastPage: ChatPage
    private var lastLoadPage = 1
    private var windowOffset: Int
    private var windowCount: Int
    private var itemsOffset: Int
    private var items = [ChatItemProtocol]()
    private let itemGenerator: (ChatMessage) -> ChatItemProtocol
    
    init(chatPage: ChatPage) {
        let count = chatPage.allPages * chatPage.messages.count
        
        self.lastPage = chatPage
        self.windowOffset = count
        self.windowCount = 0
        self.itemsOffset = count
        
        let userId = SessionManager().userId
        
        self.itemGenerator = { message -> ChatItemProtocol in
            let model = MessageModel(
                uid: message.id,
                senderId: message.writerId,
                type: TextMessageModel<MessageModel>.chatItemType,
                isIncoming: message.writerId != userId,
                date: Date(timeIntervalSince1970: message.created),
                status: .success
            )
            return ChatTextMessageModel(messageModel: model, text: message.body)
        }
        
        generateItems(chatPage.messages)
    }
}

// MARK: Public
extension ChatDataSource {
    func insert(page: ChatPage) {
        self.lastPage = page
        
        loadPrevious(page: page)
        adjustWindow(focusPosition: 0, maxWindowSize: Constants.preferredMaxWindowSize)
        delegate?.chatDataSourceDidUpdate(self, updateType: .pagination)
    }
    
    func insert(newMessage: ChatMessage) {
        let item = itemGenerator(newMessage)
        insertItem(item, position: .bottom)
        delegate?.chatDataSourceDidUpdate(self)
    }
}

// MARK: ChatDataSourceProtocol
extension ChatDataSource: ChatDataSourceProtocol {
    var hasMorePrevious: Bool {
        lastPage.currentPage < lastPage.allPages
    }
    
    var chatItems: [ChatItemProtocol] {
        let offset = windowOffset - itemsOffset
        return Array(items[offset..<offset+windowCount])
    }
    
    func loadPrevious() {
        let loadPage = lastPage.currentPage + 1
        guard lastLoadPage != loadPage else {
            return
        }
        
        lastLoadPage = loadPage
        
        didLoadNextPage?(loadPage)
    }
    
    func adjustNumberOfMessages(preferredMaxCount: Int?, focusPosition: Double, completion: (Bool) -> Void) {
        let didAdjust = adjustWindow(focusPosition: focusPosition, maxWindowSize: preferredMaxCount ?? Constants.preferredMaxWindowSize)
        completion(didAdjust)
    }
    
    var hasMoreNext: Bool { false }
    func loadNext() {}
}

// MARK: Private
private extension ChatDataSource {
    func insertItem(_ item: ChatItemProtocol, position: InsertPosition) {
        if position == .top {
            items.insert(item, at: 0)
            let shouldExpandWindow = itemsOffset == windowOffset
            itemsOffset -= 1
            if shouldExpandWindow {
                windowOffset -= 1
                windowCount += 1
            }
        } else {
            let shouldExpandWindow = itemsOffset + items.count == windowOffset + windowCount
            if shouldExpandWindow {
                windowCount += 1
            }
            items.append(item)
        }
    }
    
    func loadPrevious(page: ChatPage) {
        let previousWindowOffset = windowOffset
        let previousWindowCount = windowCount
        let nextWindowOffset = max(0, windowOffset - page.messages.count)
        generateItems(page.messages)
        let newItemsCount = previousWindowOffset - nextWindowOffset
        windowOffset = nextWindowOffset
        windowCount = previousWindowCount + newItemsCount
    }

    @discardableResult
    func adjustWindow(focusPosition: Double, maxWindowSize: Int) -> Bool {
        guard 0 <= focusPosition && focusPosition <= 1 else {
            return false
        }
        
        let sizeDiff = windowCount - maxWindowSize
        guard sizeDiff > 0 else {
            return false
        }
        
        windowOffset += Int(focusPosition * Double(sizeDiff))
        windowCount = maxWindowSize
        
        return true
    }
    
    func generateItems(_ messages: [ChatMessage]) {
        guard !messages.isEmpty else {
            return
        }
        
        for message in messages {
            let item = itemGenerator(message)
            insertItem(item, position: .top)
        }
    }
}
