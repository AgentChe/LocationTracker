//
//  OPhotoView.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 20.11.2023.
//

import UIKit

protocol OPhotoViewDelegate: AnyObject {
    func photoViewDidSelect(image: UIImage)
}

final class OPhotoView: OSlideView {
    weak var mainDelegate: OPhotoViewDelegate?
    
    lazy var skipButton = makeSkipButton()
    lazy var titleLabel = makeTitleLabel()
    lazy var photoView = makePhotoView()
    lazy var dimmedView = makePhotoDimmedView()
    lazy var editView = makeEditView()
    lazy var continueButton = makeContinueButton()
    
    private var imagePicker: ImagePicker?
    private var photo: UIImage?
    
    init(step: OnboardingView.Step, vc: UIViewController?) {
        super.init(step: step)
        
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
    }
    
    @objc
    func selectPhotoTapped() {
        imagePicker?.present(from: self)
    }
    
    @objc
    func continueTapped() {
        if let photo {
            mainDelegate?.photoViewDidSelect(image: photo)
        }
        
        onNext()
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
        view.addTarget(self, action: #selector(onNext), for: .touchUpInside)
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
        view.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
