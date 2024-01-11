//
//  EditProfileViewModel.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 11.01.2024.
//

import RxSwift
import RxCocoa

final class EditProfileViewModel {
    enum Route {
        case dismiss
    }
    
    enum Photo {
        case url(URL?)
        case image(UIImage)
    }
    
    var tryAgain: ((Error) -> (Observable<Void>))?
    
    private lazy var activity = RxActivityIndicator()
    
    private lazy var profileManager = ProfileManager()
    
    private lazy var observableRetrySingle = ObservableRetrySingle()
}

// MARK: Public
extension EditProfileViewModel {
    struct Input {
        let didChangeName: Signal<String?>
        let didChangeImage: Signal<UIImage?>
        let didSave: Signal<Void>
    }
    
    struct Output {
        let isSaveEnable: Driver<Bool>
        let isPhotoSelected: Driver<Bool>
        let name: Driver<String>
        let image: Driver<Photo>
        let route: Driver<Route>
        let activity: Driver<Bool>
    }
    
    func configure(input: Input) -> Output {
        let profile = makeProfile()
        let name = makeName(profile: profile, didChangeName: input.didChangeName)
        let image = makeImage(profile: profile, didChangeImage: input.didChangeImage)
        
        return Output(
            isSaveEnable: makeIsSaveEnable(name: name),
            isPhotoSelected: makeIsPhotoSelected(image: image),
            name: name,
            image: image,
            route: makeRoute(
                didSave: input.didSave,
                name: name,
                photo: image
            ),
            activity: activity.asDriver()
        )
    }
}

// MARK: Private
private extension EditProfileViewModel {
    func makeIsSaveEnable(name: Driver<String>) -> Driver<Bool> {
        name
            .map { name -> Bool in
                return !name.isEmpty
            }
            .startWith(false)
    }
    
    func makeIsPhotoSelected(image: Driver<Photo>) -> Driver<Bool> {
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
    
    func makeName(profile: Driver<Profile>, didChangeName: Signal<String?>) -> Driver<String> {
        let initialName = profile
            .map { $0.name }
        
        return initialName
            .flatMapLatest { initialName -> Driver<String> in
                didChangeName
                    .skip(1)
                    .map { $0 ?? "" }
                    .asDriver(onErrorDriveWith: .never())
                    .startWith(initialName)
            }
    }
    
    func makeImage(profile: Driver<Profile>, didChangeImage: Signal<UIImage?>) -> Driver<Photo> {
        let initial = profile
            .map { Photo.url($0.photoUrl) }
        
        let update = didChangeImage
            .compactMap { $0 }
            .map { Photo.image($0) }
            .asDriver(onErrorDriveWith: .never())
        
        return Driver
            .merge(initial, update)
    }
    
    func makeProfile() -> Driver<Profile> {
        profileManager
            .obtainProfile(forceUpdate: false)
            .compactMap { $0 }
            .asDriver(onErrorDriveWith: .never())
    }
    
    func makeRoute(
        didSave: Signal<Void>,
        name: Driver<String>,
        photo: Driver<Photo>
    ) -> Driver<Route> {
        func photoUrl(source: Photo) -> Single<URL?> {
            switch source {
            case .url(let url):
                return .just(url)
            case .image(let image):
                guard let photo = image.jpegData(compressionQuality: 0.5) else {
                    return .deferred { .just(nil) }
                }

                return self.profileManager
                    .upload(photo: photo)
            }
        }
        
        return didSave
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(name)
            .withLatestFrom(photo) { ($0, $1) }
            .flatMapLatest { [weak self] args -> Driver<Route> in
                guard let self else {
                    return .never()
                }
                
                func source() -> Single<Route> {
                    photoUrl(source: args.1)
                        .flatMap { photoUrl -> Single<Route> in
                            self.profileManager
                                .set(name: args.0, photoUrl: photoUrl)
                                .map { Route.dismiss }
                        }
                }
                
                func trigger(error: Error) -> Observable<Void> {
                    guard let tryAgain = self.tryAgain?(error) else {
                        return .empty()
                    }
                    
                    return tryAgain
                }
                
                return self.observableRetrySingle
                    .retry(source: { source() },
                           trigger: { trigger(error: $0) })
                    .trackActivity(self.activity)
                    .asDriver(onErrorDriveWith: .never())
            }
    }
}
