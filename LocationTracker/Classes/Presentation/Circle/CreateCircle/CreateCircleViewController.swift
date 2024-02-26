//
//  CreateCircleViewController.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 06.12.2023.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

final class CreateCircleViewController: UIViewController {
    enum Mode {
        case flow, change(EditCircleViewModel.Info)
    }
    
    lazy var mainView = CreateCircleView()
    
    private let viewModel: CreateCircleViewModel
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var closeButton = UIButton()
    
    private lazy var imagePicker = ImagePicker(presentationController: self, delegate: self)
    
    private lazy var didChangeImageTrigger = PublishRelay<UIImage?>()
    
    private let changed: ((EditCircleViewModel.Info) -> Void)?
    private let flowCompleted: (() -> Void)?
    
    private init(
        mode: Mode,
        changed: ((EditCircleViewModel.Info) -> Void)?,
        flowCompleted: (() -> Void)?
    ) {
        self.viewModel = CreateCircleViewModel(mode: mode)
        self.changed = changed
        self.flowCompleted = flowCompleted
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
    static func make(
        mode: Mode,
        changed: ((EditCircleViewModel.Info) -> Void)? = nil,
        flowCompleted: (() -> Void)? = nil
    ) -> CreateCircleViewController {
        let vc = CreateCircleViewController(mode: mode, changed: changed, flowCompleted: flowCompleted)
        vc.title = mode.title
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
            navigationController?.dismiss(animated: true) { [weak self] in
                self?.flowCompleted?()
            }
        case .selectRole(let data):
            let vc = SelectRoleViewController.make(mode: .flow(data), flowCompleted: flowCompleted)
            navigationController?.pushViewController(vc, animated: true)
        case .changed(let info):
            navigationController?.dismiss(animated: true) { [weak self] in
                self?.changed?(info)
            }
        }
    }
}

// MARK: Additional
extension CreateCircleViewController.Mode {
    var title: String {
        switch self {
        case .flow:
            return "CreateCircle.Title".localized
        case .change:
            return ""
        }
    }
}
