//
//  EditProfileViewController.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 11.01.2024.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

final class EditProfileViewController: UIViewController {
    lazy var mainView = EditProfileView()
    
    private lazy var viewModel = EditProfileViewModel()
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var imagePicker = ImagePicker(presentationController: self, delegate: self)
    
    private lazy var didChangeImageTrigger = PublishRelay<UIImage?>()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.tryAgain = { [weak self] error -> Observable<Void> in
            guard let self = self else {
                return .never()
            }

            return self.open(error: error)
        }
        
        let output = viewModel.configure(input: EditProfileViewModel.Input(
            didChangeName: mainView.nameField.rx.text.asSignal(onErrorSignalWith: .never()),
            didChangeImage: didChangeImageTrigger.asSignal(),
            didSave: mainView.saveButton.rx.tap.asSignal()
        ))
        
        output.isPhotoSelected
            .drive(Binder(mainView) { base, selected in
                base.photoDimmedView.isHidden = !selected
                base.editView.image = UIImage(named: selected ? "EditProfile.PhotoEdit" : "EditProfile.PhotoSelect")
            })
            .disposed(by: disposeBag)
        
        output.isSaveEnable
            .drive(Binder(mainView.saveButton) { base, enable in
                base.isEnabled = enable
                base.alpha = enable ? 1 : 0.4
            })
            .disposed(by: disposeBag)
        
        output.name
            .asObservable()
            .take(1)
            .asDriver(onErrorJustReturn: "")
            .drive(Binder(mainView.nameField) { base, name in
                base.text = name
            })
            .disposed(by: disposeBag)
        
        output.image
            .drive(Binder(mainView.photoView) { base, image in
                base.kf.cancelDownloadTask()
                base.image = nil
                
                switch image {
                case .url(let photo):
                    if let photo {
                        base.kf.setImage(with: photo.url)
                    }
                case .image(let img):
                    base.image = img
                }
            })
            .disposed(by: disposeBag)
        
        output.route
            .drive(Binder(self) { base, route in
                base.route(route)
            })
            .disposed(by: disposeBag)
        
        output.activity
            .drive(Binder(self) { base, activity in
                base.activity(activity)
            })
            .disposed(by: disposeBag)
        
        addPhotoSelectionAction()
        mainView.nameField.delegate = self
    }
}

// MARK: ImagePickerDelegate
extension EditProfileViewController: ImagePickerDelegate {
    func didSelect(image: UIImage?) {
        didChangeImageTrigger.accept(image)
    }
}

// MARK: UITextFieldDelegate
extension EditProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: Public
extension EditProfileViewController {
    static func make() -> EditProfileViewController {
        let vc = EditProfileViewController()
        vc.navigationItem.title = "EditProfile.Title".localized
        vc.navigationItem.backButtonTitle = " "
        return vc
    }
}

// MARK: Private
private extension EditProfileViewController {
    func open(error: Error) -> Observable<Void> {
        Observable<Void>
            .create { [weak self] observe in
                guard let self = self else {
                    return Disposables.create()
                }
                
                let vc = TryAgainViewController.make(error: error) {
                    observe.onNext(())
                }
                self.present(vc, animated: true)
                
                return Disposables.create()
            }
    }
    
    func addPhotoSelectionAction() {
        let tapGesture = UITapGestureRecognizer()
        mainView.photoView.isUserInteractionEnabled = true
        mainView.photoView.addGestureRecognizer(tapGesture)
        
        tapGesture.rx.event
            .bind(to: Binder(self) { base, event in
                base.imagePicker.present(from: base.mainView)
            })
            .disposed(by: disposeBag)
    }
    
    func route(_ route: EditProfileViewModel.Route) {
        switch route {
        case .dismiss:
            navigationController?.dismiss(animated: true)
        }
    }
    
    func activity(_ activity: Bool) {
        mainView.saveButton.isHidden = activity
        
        activity ? mainView.preloader.startAnimating() : mainView.preloader.stopAnimating()
    }
}
