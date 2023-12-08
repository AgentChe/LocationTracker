//
//  CreateCircleViewModel.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 06.12.2023.
//

import RxSwift
import RxCocoa

final class CreateCircleViewModel {
    enum Route {
        case dismiss, selectRole(CreateCircleCombineData)
    }
}

// MARK: Public
extension CreateCircleViewModel {
    struct Input {
        let didChangeName: Signal<String?>
        let didChangeImage: Signal<UIImage?>
        let didTapContinue: Signal<Void>
        let didTapClose: Signal<Void>
    }
    
    struct Output {
        let isContinueEnable: Driver<Bool>
        let isPhotoSelected: Driver<Bool>
        let image: Driver<UIImage?>
        let route: Driver<Route>
    }
    
    func configure(input: Input) -> Output {
        let name = input.didChangeName
            .map { $0 ?? "" }
            .asDriver(onErrorDriveWith: .never())
            .startWith("")
        let image = makeImage(didChangeImage: input.didChangeImage)
        
        return Output(
            isContinueEnable: makeIsContinueEnable(name: name),
            isPhotoSelected: makeIsPhotoSelected(didChangeImage: input.didChangeImage),
            image: image,
            route: makeRoute(
                didTapClose: input.didTapClose,
                didTapContinue: input.didTapContinue,
                name: name,
                image: image
            )
        )
    }
}

// MARK: Private
private extension CreateCircleViewModel {
    func makeIsContinueEnable(name: Driver<String>) -> Driver<Bool> {
        name
            .map { !$0.isEmpty }
            .startWith(false)
    }
    
    func makeIsPhotoSelected(didChangeImage: Signal<UIImage?>) -> Driver<Bool> {
        didChangeImage
            .map { $0 != nil }
            .startWith(false)
            .asDriver(onErrorDriveWith: .never())
    }
    
    func makeImage(didChangeImage: Signal<UIImage?>) -> Driver<UIImage?> {
        didChangeImage
            .startWith(nil)
            .asDriver(onErrorDriveWith: .never())
    }
    
    func makeRoute(
        didTapClose: Signal<Void>,
        didTapContinue: Signal<Void>,
        name: Driver<String>,
        image: Driver<UIImage?>
    ) -> Driver<Route> {
        let close = didTapClose
            .map { Route.dismiss }
            .asDriver(onErrorDriveWith: .never())
        
        let selectRole = didTapContinue
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(name)
            .withLatestFrom(image) { ($0, $1) }
            .map { name, image -> Route in
                let data = CreateCircleCombineData(name: name, image: image)
                return .selectRole(data)
            }
        
        return Driver
            .merge(close, selectRole)
    }
}
