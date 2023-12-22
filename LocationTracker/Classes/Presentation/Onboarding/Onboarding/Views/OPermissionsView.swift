//
//  OPermissionsView.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 21.11.2023.
//

import UIKit

protocol OPermissionsViewDelegate: AnyObject {
    func permissionsViewDidReceive(pushToken: String?)
}

final class OPermissionsView: OSlideView {
    weak var mainDelegate: OPermissionsViewDelegate?
    
    lazy var imageView = makeImageView()
    lazy var titleLabel = makeTitleLabel()
    lazy var locationPermissionView = makeLocationPermissionView()
    lazy var pushPermissionView = makePushPermissionView()
    lazy var continueButton = makeContinueButton()
    lazy var enablePermissionView = makeEnablePermissionView()
    
    override init(step: OnboardingView.Step) {
        super.init(step: step)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: PushNotificationsDelegate
extension OPermissionsView: PushNotificationsDelegate {
    func pushNotificationsDidReceive(authorizationStatus: PushNotificationsAuthorizationStatus) {}
    func pushNotificationsDidReceive(application: UIApplication, model: PushNotificationsModel) {}
    
    func pushNotificationsDidReceive(token: String?) {
        PushNotificationsManager.shared.remove(observer: self)
        
        mainDelegate?.permissionsViewDidReceive(pushToken: token)
        
        if locationPermissionView.switchView.isOn {
            requestGeoLocationPermission()
        } else {
            onNext()
        }
    }
}

// MARK: GeoLocationManagerDelegate
extension OPermissionsView: GeoLocationManagerDelegate {
    func geoLocationDidChange(permissionStatus: GeoLocationPermissionStatus) {
        if permissionStatus != .notDetermined {
            GeoLocationManager.shared.remove(observer: self)
            
            onNext()
        }
    }
    
    func geoLocationDidUpdate(locations: [Location]) {}
}

// MARK: Private
private extension OPermissionsView {
    func initialize() {
        backgroundColor = Appearance.background1
    }
    
    @objc
    func continueTapped() {
        if pushPermissionView.switchView.isOn {
            requestPushPermission()
        } else if locationPermissionView.switchView.isOn {
            requestGeoLocationPermission()
        } else {
            enablePermissionView.show { [weak self] result in
                guard let self, let result else {
                    return
                }
                
                switch result {
                case .enable:
                    self.locationPermissionView.switchView.isOn = true
                    self.pushPermissionView.switchView.isOn = true
                case .skip:
                    self.onNext()
                }
            }
        }
    }
    
    func requestPushPermission() {
        PushNotificationsManager.shared.add(observer: self)
        PushNotificationsManager.shared.requestAuthorization()
    }
    
    func requestGeoLocationPermission() {
        GeoLocationManager.shared.add(observer: self)
        GeoLocationManager.shared.requestAlwaysPermission()
    }
}

// MARK: Make constraints
private extension OPermissionsView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 217.scale),
            imageView.heightAnchor.constraint(equalToConstant: 200.scale),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: ScreenSize.isIphoneXFamily ? 104.scale : 60.scale)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 24.scale)
        ])
        
        NSLayoutConstraint.activate([
            locationPermissionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            locationPermissionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            locationPermissionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 14.scale)
        ])
        
        NSLayoutConstraint.activate([
            pushPermissionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            pushPermissionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            pushPermissionView.topAnchor.constraint(equalTo: locationPermissionView.bottomAnchor, constant: 23.scale)
        ])
        
        NSLayoutConstraint.activate([
            continueButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            continueButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            continueButton.heightAnchor.constraint(equalToConstant: 56.scale),
            continueButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: ScreenSize.isIphoneXFamily ? -60.scale : -30.scale)
        ])
        
        NSLayoutConstraint.activate([
            enablePermissionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            enablePermissionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            enablePermissionView.topAnchor.constraint(equalTo: topAnchor),
            enablePermissionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension OPermissionsView {
    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "Onboarding.Permissions")
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.black2)
            .font(Fonts.RobotoCondensed.medium(size: 24.scale))
            .lineHeight(33.6.scale)
            .textAlignment(.left)
        
        let view = UILabel()
        view.attributedText = "Onboarding.Permissions.Title".localized.attributed(with: attrs)
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeLocationPermissionView() -> PermissionView {
        let view = PermissionView(permission: .location)
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makePushPermissionView() -> PermissionView {
        let view = PermissionView(permission: .push)
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeContinueButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.white)
            .font(Fonts.RobotoCondensed.medium(size: 16.scale))
        
        let view = UIButton()
        view.setAttributedTitle("Continue".localized.attributed(with: attrs), for: .normal)
        view.backgroundColor = Appearance.primary1
        view.layer.cornerRadius = 20.scale
        view.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeEnablePermissionView() -> EnablePermissionView {
        let view = EnablePermissionView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
