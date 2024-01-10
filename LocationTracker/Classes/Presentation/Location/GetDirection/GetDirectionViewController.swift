//
//  GetDirectionViewController.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 10.01.2024.
//

import UIKit
import RxSwift
import RxCocoa

class GetDirectionViewController: UIViewController {
    enum Direction {
        case googleMaps, appleMaps
        
        var scheme: String? {
            switch self {
            case .googleMaps:
                return "comgooglemaps://"
            case .appleMaps:
                return nil
            }
        }
        
        var isAvailable: Bool {
            switch self {
            case .googleMaps:
                let url = URL(string: scheme!)!
                return UIApplication.shared.canOpenURL(url)
            case .appleMaps:
                return true
            }
        }
    }
    
    lazy var mainView = GetDirectionView()

    private lazy var disposeBag = DisposeBag()
    
    private let completion: (Direction) -> Void
    
    private init(completion: @escaping (Direction) -> Void) {
        self.completion = completion
        
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
        
        Signal
            .merge(
                mainView.googleMapsButton.rx.tap
                    .map { Direction.googleMaps }
                    .asSignal(onErrorSignalWith: .never()),
                mainView.appleMapsButton.rx.tap
                    .map { Direction.appleMaps }
                    .asSignal(onErrorSignalWith: .never())
            )
            .emit(to: Binder(self) { base, direction in
                base.dismiss {
                    base.completion(direction)
                }
            })
            .disposed(by: disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        animateShow()
    }
}

// MARK: Make
extension GetDirectionViewController {
    static func make(completion: @escaping (Direction) -> Void) -> GetDirectionViewController {
        let vc = GetDirectionViewController(completion: completion)
        vc.modalPresentationStyle = .overFullScreen
        return vc
    }
}

// MARK: Private
private extension GetDirectionViewController {
    func animateShow() {
        mainView.containerYConstraint.isActive = false
        mainView.containerYConstraint = mainView.container.bottomAnchor.constraint(equalTo: mainView.bottomAnchor)
        mainView.containerYConstraint.isActive = true

        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.mainView.dimmedView.alpha = 0.6
            self?.mainView.layoutIfNeeded()
        })
    }

    func dismiss(completion: (() -> Void)? = nil) {
        animateDismiss { [weak self] in
            self?.dismiss(animated: false) {
                completion?()
            }
        }
    }
    
    func animateDismiss(completion: @escaping (() -> Void)) {
        mainView.containerYConstraint.isActive = false
        mainView.containerYConstraint = mainView.container.topAnchor.constraint(equalTo: mainView.bottomAnchor)
        mainView.containerYConstraint.isActive = true

        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.mainView.dimmedView.alpha = 0
            self?.mainView.layoutIfNeeded()
        }, completion: { result in
            completion()
        })
    }
}
