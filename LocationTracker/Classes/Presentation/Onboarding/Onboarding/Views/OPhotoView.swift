//
//  OPhotoView.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 20.11.2023.
//

import UIKit
import RxSwift
import RxCocoa

final class OPhotoView: OSlideView {
    lazy var skipButton = makeSkipButton()
    lazy var titleLabel = makeTitleLabel()
    lazy var photoView = makePhotoView()
    lazy var dimmedView = makePhotoDimmedView()
    lazy var editView = makeEditView()
    lazy var continueButton = makeContinueButton()
    lazy var preloader = makePreloader()
    
    private var imagePicker: ImagePicker?
    private var name: String?
    private var photo: UIImage?
    
    private weak var vc: UIViewController?
    
    private lazy var activity = RxActivityIndicator()
    
    private lazy var profileManager = ProfileManager()
    
    private lazy var observableRetrySingle = ObservableRetrySingle()
    
    private lazy var disposeBag = DisposeBag()
    
    init(step: OnboardingView.Step, vc: UIViewController?) {
        super.init(step: step)
        
        self.vc = vc
        
        if let vc {
            imagePicker = ImagePicker(presentationController: vc, delegate: self)
        }
        
        makeConstraints()
        initialize()
        photoChanged()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: ONameViewDelegate
extension OPhotoView: ONameViewDelegate {
    func nameViewDidEnter(name: String) {
        self.name = name
    }
}

// MARK: ImagePickerDelegate
extension OPhotoView: ImagePickerDelegate {
    func didSelect(image: UIImage?) {
        self.photo = image
        photoView.image = image
        
        photoChanged()
    }
}

// MARK: Private
private extension OPhotoView {
    func initialize() {
        backgroundColor = Appearance.background1
        
        activity
            .drive(Binder(self) { base, activity in
                activity ? base.preloader.startAnimating() : base.preloader.stopAnimating()
                base.continueButton.isHidden = activity
                base.skipButton.isHidden = activity
            })
            .disposed(by: disposeBag)
        
        Signal
            .merge(
                continueButton.rx.tap.asSignal(),
                skipButton.rx.tap.asSignal()
            )
            .flatMapLatest { [weak self] void -> Driver<Void> in
                guard let self else {
                    return .never()
                }
                
                func source() -> Single<Void> {
                    var photo: Single<Image?> {
                        guard let photo = self.photo?.jpegData(compressionQuality: 0.5) else {
                            return .deferred { .just(nil) }
                        }
                        
                        return self.profileManager
                            .upload(photo: photo)
                    }
                    
                    return photo
                        .flatMap { [weak self] photo -> Single<Void> in
                            guard let self else {
                                return .never()
                            }
                            
                            return self.profileManager
                                .set(
                                    name: self.name,
                                    photo: photo
                                )
                        }
                }
                
                func error(err: Error) -> Observable<Void> {
                    self.open(error: err)
                }
                
                return self.observableRetrySingle
                    .retry(source: { source() },
                           trigger: { error(err: $0) })
                    .trackActivity(self.activity)
                    .asDriver(onErrorDriveWith: .never())
            }
            .drive(Binder(self) { base, void in
                base.onNext()
            })
            .disposed(by: disposeBag)
    }
    
    @objc
    func selectPhotoTapped() {
        imagePicker?.present(from: self)
    }
    
    func open(error: Error) -> Observable<Void> {
        Observable<Void>
            .create { [weak self] observe in
                guard let self = self else {
                    return Disposables.create()
                }
                
                let vc = TryAgainViewController.make(error: error) {
                    observe.onNext(())
                }
                self.vc?.present(vc, animated: true)
                
                return Disposables.create()
            }
    }
    
    func photoChanged() {
        let selected = photo != nil
        dimmedView.isHidden = !selected
        editView.image = UIImage(named: selected ? "Onboarding.Photo.Edit" : "Onboarding.Photo.Select")
        continueButton.isEnabled = selected
        continueButton.alpha = selected ? 1 : 0.4
    }
}

// MARK: Make constraints
private extension OPhotoView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            skipButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            skipButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 8.scale)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32.scale),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32.scale),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: ScreenSize.isIphoneXFamily ? 104.scale : 60.scale)
        ])
        
        NSLayoutConstraint.activate([
            photoView.widthAnchor.constraint(equalToConstant: 170.scale),
            photoView.heightAnchor.constraint(equalToConstant: 170.scale),
            photoView.centerXAnchor.constraint(equalTo: centerXAnchor),
            photoView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            dimmedView.leadingAnchor.constraint(equalTo: photoView.leadingAnchor),
            dimmedView.trailingAnchor.constraint(equalTo: photoView.trailingAnchor),
            dimmedView.topAnchor.constraint(equalTo: photoView.topAnchor),
            dimmedView.bottomAnchor.constraint(equalTo: photoView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            editView.widthAnchor.constraint(equalToConstant: 40.scale),
            editView.heightAnchor.constraint(equalToConstant: 40.scale),
            editView.centerXAnchor.constraint(equalTo: photoView.centerXAnchor),
            editView.centerYAnchor.constraint(equalTo: photoView.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            continueButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            continueButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            continueButton.heightAnchor.constraint(equalToConstant: 56.scale),
            continueButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: ScreenSize.isIphoneXFamily ? -60.scale : -30.scale)
        ])
        
        NSLayoutConstraint.activate([
            preloader.widthAnchor.constraint(equalToConstant: 45.scale),
            preloader.heightAnchor.constraint(equalToConstant: 45.scale),
            preloader.centerXAnchor.constraint(equalTo: continueButton.centerXAnchor),
            preloader.centerYAnchor.constraint(equalTo: continueButton.centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension OPhotoView {
    func makeSkipButton() -> TapAreaButton {
        let attrs = TextAttributes()
            .textColor(Appearance.primary1)
            .font(Fonts.RobotoCondensed.medium(size: 18.scale))
        
        let view = TapAreaButton()
        view.setAttributedTitle("Onboarding.Photo.Skip".localized.attributed(with: attrs), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.black2)
            .font(Fonts.RobotoCondensed.medium(size: 32.scale))
            .lineHeight(44.8.scale)
            .textAlignment(.center)
        
        let view = UILabel()
        view.attributedText = "Onboarding.Photo.Title".localized.attributed(with: attrs)
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makePhotoView() -> UIImageView {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectPhotoTapped))
        
        let view = UIImageView()
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tapGesture)
        view.backgroundColor = Appearance.background2
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 60.scale
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makePhotoDimmedView() -> UIView {
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.backgroundColor = Appearance.black2.withAlphaComponent(0.2)
        view.layer.cornerRadius = 60.scale
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeEditView() -> UIImageView {
        let view = UIImageView()
        view.isUserInteractionEnabled = false
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeContinueButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.white)
            .font(Fonts.RobotoCondensed.medium(size: 16.scale))
        
        let view = UIButton()
        view.setAttributedTitle("Next".localized.attributed(with: attrs), for: .normal)
        view.backgroundColor = Appearance.primary1
        view.layer.cornerRadius = 20.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makePreloader() -> UIActivityIndicatorView {
        let view = UIActivityIndicatorView()
        view.hidesWhenStopped = true
        view.style = .large
        view.color = Appearance.primary1
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
