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
        case dismiss, selectRole(CreateCircleCombineData), changed(EditCircleViewModel.Info)
    }
    
    private let mode: Driver<CreateCircleViewController.Mode>
    
    init(mode: CreateCircleViewController.Mode) {
        self.mode = BehaviorRelay(value: mode).asDriver()
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
        let name: Driver<String>
        let image: Driver<EditCircleName.Photo>
        let route: Driver<Route>
    }
    
    func configure(input: Input) -> Output {
        let name = makeName(didChangeName: input.didChangeName)
        let image = makeImage(didChangeImage: input.didChangeImage)
        
        return Output(
            isContinueEnable: makeIsContinueEnable(name: name),
            isPhotoSelected: makeIsPhotoSelected(image: image),
            name: name,
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
            .map { name -> Bool in
                return !name.isEmpty
            }
            .startWith(false)
    }
    
    func makeIsPhotoSelected(image: Driver<EditCircleName.Photo>) -> Driver<Bool> {
        image
            .map { image -> Bool in
                switch image {
                case .image:
                    return true
                case .url(let url):
                    return url != nil
                }
            }
    }
    
    func makeName(didChangeName: Signal<String?>) -> Driver<String> {
        let initialName = mode
            .map { mode -> String in
                guard case let .change(info) = mode else {
                    return ""
                }
                
                return info.0
            }
        
        return initialName
            .flatMapLatest { initialName -> Driver<String> in
                didChangeName
                    .skip(1)
                    .map { $0 ?? "" }
                    .asDriver(onErrorDriveWith: .never())
                    .startWith(initialName)
            }
    }
    
    func makeImage(didChangeImage: Signal<UIImage?>) -> Driver<EditCircleName.Photo> {
        let initial = mode
            .map { mode -> EditCircleName.Photo in
                guard case let .change(info) = mode else {
                    return .url(nil)
                }
                
                return info.1
            }
        
        let update = didChangeImage
            .compactMap { $0 }
            .map { EditCircleName.Photo.image($0) }
            .asDriver(onErrorDriveWith: .never())
        
        return Driver
            .merge(initial, update)
    }
    
    func makeRoute(
        didTapClose: Signal<Void>,
        didTapContinue: Signal<Void>,
        name: Driver<String>,
        image: Driver<EditCircleName.Photo>
    ) -> Driver<Route> {
        let close = didTapClose
            .map { Route.dismiss }
            .asDriver(onErrorDriveWith: .never())
        
        let selectRole = didTapContinue
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(name)
            .withLatestFrom(image) { ($0, $1) }
            .withLatestFrom(mode) { ($0.0, $0.1, $1) }
            .map { name, image, mode -> Route in
                switch mode {
                case .flow:
                    var img: UIImage? {
                        guard case let .image(img) = image else {
                            return nil
                        }
                        
                        return img
                    }
                    
                    let data = CreateCircleCombineData(name: name, image: img)
                    return .selectRole(data)
                case .change:
                    let info = (name, image)
                    return .changed(info)
                }
            }
        
        return Driver
            .merge(close, selectRole)
    }
}
