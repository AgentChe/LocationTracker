//
//  DemoTextMessageViewModelBuilder.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 08.02.2024.
//

import Foundation
import Chatto
import ChattoAdditions

// TODO
typealias DemoTextMessageViewModel = TextMessageViewModel<DemoTextMessageModel>

class DemoTextMessageViewModelBuilder: ViewModelBuilderProtocol {

    typealias ObservableImageProvider = (DemoTextMessageModel) -> Observable<UIImage?>

    private static let defaultObservableImageProvider: ObservableImageProvider = { _ in Observable(UIImage(named: "userAvatar")) }

    private let imageProvider: ObservableImageProvider

    init(imageProvider: @escaping ObservableImageProvider = DemoTextMessageViewModelBuilder.defaultObservableImageProvider) {
        self.imageProvider = imageProvider
    }

    let messageViewModelBuilder = MessageViewModelDefaultBuilder()

    func createViewModel(_ textMessage: DemoTextMessageModel) -> DemoTextMessageViewModel {
        let messageViewModel = self.messageViewModelBuilder.createMessageViewModel(textMessage)
        let textMessageViewModel = DemoTextMessageViewModel(textMessage: textMessage, messageViewModel: messageViewModel)
        textMessageViewModel.avatarImage = self.imageProvider(textMessage)
        return textMessageViewModel
    }

    func canCreateViewModel(fromModel model: Any) -> Bool {
        return model is DemoTextMessageModel
    }
}
