//
//  TimeSeparatorPresenterBuilder.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 08.02.2024.
//

import UIKit
import Chatto

final class TimeSeparatorPresenterBuilder: ChatItemPresenterBuilderProtocol {
    func canHandleChatItem(_ chatItem: ChatItemProtocol) -> Bool {
        chatItem is TimeSeparatorModel
    }

    func createPresenterWithChatItem(_ chatItem: ChatItemProtocol) -> ChatItemPresenterProtocol {
        TimeSeparatorPresenter(timeSeparatorModel: chatItem as! TimeSeparatorModel)
    }

    var presenterType: ChatItemPresenterProtocol.Type {
        TimeSeparatorPresenter.self
    }
}

final class TimeSeparatorPresenter: ChatItemPresenterProtocol {
    let isItemUpdateSupported = false
    let timeSeparatorModel: TimeSeparatorModel
    
    private static let cellReuseIdentifier = TimeSeparatorCollectionViewCell.self.description()
    
    init (timeSeparatorModel: TimeSeparatorModel) {
        self.timeSeparatorModel = timeSeparatorModel
    }

    static func registerCells(_ collectionView: UICollectionView) {
        collectionView.register(TimeSeparatorCollectionViewCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
    }

    func update(with chatItem: ChatItemProtocol) {}

    func dequeueCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.dequeueReusableCell(withReuseIdentifier: TimeSeparatorPresenter.cellReuseIdentifier, for: indexPath)
    }

    func configureCell(_ cell: UICollectionViewCell, decorationAttributes: ChatItemDecorationAttributesProtocol?) {
        guard let timeSeparatorCell = cell as? TimeSeparatorCollectionViewCell else {
            assert(false, "expecting status cell")
            return
        }

        timeSeparatorCell.setup(time: timeSeparatorModel.date)
    }

    var canCalculateHeightInBackground: Bool {
        true
    }

    func heightForCell(maximumWidth width: CGFloat, decorationAttributes: ChatItemDecorationAttributesProtocol?) -> CGFloat {
        24.scale
    }
}

