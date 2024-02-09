//
//  ChatItemsDecorator.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 08.02.2024.
//

import Chatto
import ChattoAdditions

final class ChatItemsDecorator: ChatItemsDecoratorProtocol {
    struct Constants {
        static let shortSeparation: CGFloat = 3.scale
        static let normalSeparation: CGFloat = 10.scale
        static let timeIntervalThresholdToIncreaseSeparation: TimeInterval = 120
    }
}

// MARK: Public
extension ChatItemsDecorator {
    func decorateItems(_ chatItems: [ChatItemProtocol]) -> [DecoratedChatItem] {
        var decoratedChatItems = [DecoratedChatItem]()
        let calendar = Calendar.current
        
        for (index, chatItem) in chatItems.enumerated() {
            let next: ChatItemProtocol? = (index + 1 < chatItems.count) ? chatItems[index + 1] : nil
            let prev: ChatItemProtocol? = (index > 0) ? chatItems[index - 1] : nil
            
            let bottomMargin = separationAfterItem(chatItem, next: next)
            var showsTail = false
            var addTimeSeparator = false
            
            if let currentMessage = chatItem as? MessageModelProtocol {
                if let nextMessage = next as? MessageModelProtocol {
                    showsTail = currentMessage.senderId != nextMessage.senderId
                } else {
                    showsTail = true
                }
                
                if let previousMessage = prev as? MessageModelProtocol {
                    addTimeSeparator = !calendar.isDate(currentMessage.date, inSameDayAs: previousMessage.date)
                } else {
                    addTimeSeparator = true
                }
                
                if addTimeSeparator {
                    let dateTimeStamp = DecoratedChatItem(chatItem: TimeSeparatorModel(uid: "\(currentMessage.uid)-time-separator", date: currentMessage.date.toWeekDayAndDateString()), decorationAttributes: nil)
                    decoratedChatItems.append(dateTimeStamp)
                }
            }
            
            let messageDecorationAttributes = BaseMessageDecorationAttributes(
                canShowFailedIcon: false,
                isShowingTail: showsTail
            )
            
            decoratedChatItems.append(
                DecoratedChatItem(
                    chatItem: chatItem,
                    decorationAttributes: ChatItemDecorationAttributes(
                        bottomMargin: bottomMargin,
                        messageDecorationAttributes: messageDecorationAttributes
                    )
                )
            )
        }
        
        return decoratedChatItems
    }
}

// MARK: Private
private extension ChatItemsDecorator {
    func separationAfterItem(_ current: ChatItemProtocol?, next: ChatItemProtocol?) -> CGFloat {
        guard let nexItem = next else {
            return 0
        }
        
        guard let currentMessage = current as? MessageModelProtocol else {
            return Constants.normalSeparation
        }
        
        guard let nextMessage = nexItem as? MessageModelProtocol else {
            return Constants.normalSeparation
        }

        if currentMessage.senderId != nextMessage.senderId {
            return Constants.normalSeparation
        } else if nextMessage.date.timeIntervalSince(currentMessage.date) > Constants.timeIntervalThresholdToIncreaseSeparation {
            return Constants.normalSeparation
        } else {
            return Constants.shortSeparation
        }
    }
}

// MARK: Additional
private extension Date {
    func toWeekDayAndDateString() -> String {
        Date.weekdayAndDateStampDateFormatter.string(from: self)
    }
    
    static let weekdayAndDateStampDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        dateFormatter.dateFormat = "EEEE, MMM dd yyyy"
        return dateFormatter
    }()
}
