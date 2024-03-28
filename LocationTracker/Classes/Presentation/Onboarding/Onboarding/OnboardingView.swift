//
//  OnboardingView.swift
//  Soccer
//
//  Created by Андрей Чернышев on 23.08.2022.
//

import UIKit

final class OnboardingView: UIView {
    enum Step: Int {
        case welcome, name, photo, circle, intro1, intro2, sosInstruction, pin, permissions, preloader
    }
    
    var didFinish: (() -> Void)?
    var didTapDisclaimer: (() -> Void)?
    
    lazy var nameView = ONameView(step: .name)
    lazy var photoView = OPhotoView(step: .photo, vc: vc)
    lazy var circleView = OCircleView(step: .circle)
    lazy var pinView = OPINView(step: .pin)
    lazy var permissionsView = OPermissionsView(step: .permissions)
    lazy var preloaderView = OPreloaderView(step: .preloader, combineData: combineData, vc: vc)
    
    lazy var contentViews: [OSlideView] = {
        [
            OWelcomeView(step: .welcome),
            nameView,
            photoView,
            circleView,
            OIntroView(step: .intro1, intro: .one),
            OIntroView(step: .intro2, intro: .two),
            OSOSInstructionView(step: .sosInstruction),
            pinView,
            permissionsView,
            preloaderView
        ]
    }()
    
    private var step = Step.welcome
    
    private lazy var combineData = OnboardingCombineData()
    
    private weak var vc: UIViewController?
    
    init(vc: UIViewController) {
        self.vc = vc
        
        super.init(frame: .zero)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: OSlideViewDelegate
extension OnboardingView: OSlideViewDelegate {
    func slideViewDidNext(from step: Step) {
        let nextRawValue = step.rawValue + 1
        
        guard let nextStep = Step(rawValue: nextRawValue) else {
            didFinish?()
            
            return
        }
        
        openPaygateIfNeeded()
        scroll(to: nextStep)
    }
    
    func slideViewDidBack(from step: OnboardingView.Step) {
        let previousRawValue = step.rawValue - 1
        
        guard let previousStep = Step(rawValue: previousRawValue) else {
            return
        }
        
        scroll(to: previousStep)
    }
    
    func slideViewDidTapDisclaimer() {
        didTapDisclaimer?()
    }
}

// MARK: Private
private extension OnboardingView {
    func initialize() {
        contentViews
            .enumerated()
            .forEach { index, view in
                view.frame.size = CGSize(width: UIScreen.main.bounds.width,
                                         height: UIScreen.main.bounds.height)
                
                view.clipsToBounds = true
                view.delegate = self
                
                if index == 0 {
                    view.frame.origin = CGPoint(x: 0, y: 0)
                    addSubview(view)
                }
            }
        
        nameView.add(observer: circleView)
        nameView.add(observer: photoView)
        pinView.mainDelegate = combineData
        permissionsView.mainDelegate = combineData
        
        circleView.onSkip = { [weak self] in
            self?.scroll(to: .intro1)
        }
        
        circleView.createCircle = { [weak self] in
            let vc = CreateCircleViewController.make(mode: .flow, flowCompleted: { [weak self] in
                self?.scroll(to: .intro1)
            })
            let nc = NavigationController(rootViewController: vc)
            self?.vc?.present(nc, animated: true)
        }
        
        circleView.joinToCircle = { [weak self] in
            let vc = JoinToCircleViewController.make { [weak self] in
                self?.scroll(to: .intro1)
            }
            let nc = NavigationController(rootViewController: vc)
            self?.vc?.present(nc, animated: true)
        }
    }
    
    func scroll(to newStep: Step) {
        let currentIndex = step.rawValue
        let scrollToIndex = newStep.rawValue
        
        let direction = scrollToIndex > currentIndex ? 1 : -1
        
        let indices = contentViews.indices
        
        guard indices.contains(currentIndex), indices.contains(scrollToIndex) else {
            return
        }

        let currentView = contentViews[currentIndex]
        let scrollToView = contentViews[scrollToIndex]
        
        scrollToView.frame.origin = CGPoint(x: 375.scale * CGFloat(direction), y: 0)
        addSubview(scrollToView)
        
        UIView.animate(withDuration: 0.3, animations: {
            currentView.frame.origin = CGPoint(x: 375.scale * CGFloat(-direction), y: 0)
            scrollToView.frame.origin = CGPoint(x: 0, y: 0)
        }, completion: { [weak self] result in
            guard let self = self else {
                return
            }
            
            currentView.removeFromSuperview()
            
            scrollToView.moveToThis()
            
            self.step = newStep
        })
    }
    
    func openPaygateIfNeeded() {
        guard step == .photo else {
            return
        }
        
        let paygateVC = PaygateViewController.make()
        vc?.present(paygateVC, animated: true)
    }
}
