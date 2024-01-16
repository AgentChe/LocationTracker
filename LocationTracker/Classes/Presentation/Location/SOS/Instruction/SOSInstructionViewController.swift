//
//  SOSInstructionViewController.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 16.01.2024.
//

import UIKit

final class SOSInstructionViewController: UIViewController {
    lazy var mainView = SOSInstructionView()
    
    override func loadView() {
        view = mainView
    }
}

// MARK: Public
extension SOSInstructionViewController {
    static func make() -> SOSInstructionViewController {
        SOSInstructionViewController()
    }
}
