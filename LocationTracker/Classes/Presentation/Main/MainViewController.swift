//
//  MainViewController.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 21.12.2023.
//

import UIKit
import RxSwift

final class MainViewController: UIViewController {
    lazy var mainView = MainView()
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var coordinator = MainViewCoordinator(parentVC: self)
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rx.methodInvoked(#selector(UIViewController.viewDidLayoutSubviews))
            .take(1)
            .bind(to: Binder(self) { base, void in
                base.update(selectedTab: .location)
            })
            .disposed(by: disposeBag)
        
        addActionsToTabs()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }
}

// MARK: Make
extension MainViewController {
    static func make() -> MainViewController {
        let vc = MainViewController()
        vc.navigationItem.backButtonTitle = " "
        return vc
    }
}

// MARK: Private
private extension MainViewController {
    func addActionsToTabs() {
        Observable
            .merge([
                mainView.tabView.locationItem
                    .rx.tap.map { TabView.Tab.location },
                mainView.tabView.chatsItem
                    .rx.tap.map { TabView.Tab.chats },
                mainView.tabView.profileItem
                    .rx.tap.map { TabView.Tab.profile }
            ])
            .bind(to: Binder(self) { base, tab in
                base.update(selectedTab: tab)
            })
            .disposed(by: disposeBag)
    }
    
    func update(selectedTab: TabView.Tab) {
        coordinator.change(tab: selectedTab)
    }
}
