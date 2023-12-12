//
//  CreateCircleViewController.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 06.12.2023.
//

import UIKit
import RxSwift
import RxCocoa

final class CreateCircleViewController: UIViewController {
    lazy var mainView = CreateCircleView()
    
    private lazy var viewModel = CreateCircleViewModel()
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var closeButton = UIButton()
    
    private lazy var imagePicker = ImagePicker(presentationController: self, delegate: self)
    
    private lazy var didChangeImageTrigger = PublishRelay<UIImage?>()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let output = viewModel.configure(input: CreateCircleViewModel.Input(
            didChangeName: mainView.nameField.rx.text.asSignal(onErrorSignalWith: .never()),
            didChangeImage: didChangeImageTrigger.asSignal(),
            didTapContinue: mainView.saveButton.rx.tap.asSignal(),
            didTapClose: closeButton.rx.tap.asSignal()
        ))
        
        output.isPhotoSelected
            .drive(Binder(mainView) { base, selected in
                base.photoDimmedView.isHidden = !selected
                base.editView.image = UIImage(named: selected ? "CreateCircle.PhotoEdit" : "CreateCircle.PhotoSelect")
            })
            .disposed(by: disposeBag)
        
        output.isContinueEnable
            .drive(Binder(mainView.saveButton) { base, enable in
                base.isEnabled = enable
                base.alpha = enable ? 1 : 0.4
            })
            .disposed(by: disposeBag)
        
        output.image
            .drive(Binder(mainView.photoView) { base, image in
                base.image = image
            })
            .disposed(by: disposeBag)
        
        output.route
            .drive(Binder(self) { base, route in
                base.route(route)
            })
            .disposed(by: disposeBag)
        
        addCloseButton()
        addPhotoSelectionAction()
        mainView.nameField.delegate = self
    }
}

// MARK: ImagePickerDelegate
extension CreateCircleViewController: ImagePickerDelegate {
    func didSelect(image: UIImage?) {
        didChangeImageTrigger.accept(image)
    }
}

// MARK: UITextFieldDelegate
extension CreateCircleViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: Public
extension CreateCircleViewController {
    static func make() -> CreateCircleViewController {
        let vc = CreateCircleViewController()
        vc.title = "CreateCircle.Title".localized
        vc.navigationItem.backButtonTitle = " "
        return vc
    }
}

// MARK: Private
private extension CreateCircleViewController {
    func addCloseButton() {
        closeButton.setImage(UIImage(named: "CreateCircle.Close"), for: .normal)
        
        let item = UIBarButtonItem(customView: closeButton)
        item.customView?.translatesAutoresizingMaskIntoConstraints = false
        
        item.customView?.widthAnchor.constraint(equalToConstant: 24.scale).isActive = true
        item.customView?.heightAnchor.constraint(equalToConstant: 24.scale).isActive = true
        
        navigationItem.rightBarButtonItem = item
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
    
    func route(_ route: CreateCircleViewModel.Route) {
        switch route {
        case .dismiss:
            navigationController?.dismiss(animated: true)
        case .selectRole(let data):
            let vc = SelectRoleViewController.make(mode: .flow(data))
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
