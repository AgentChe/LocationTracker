//
//  OCirclePreloaderView.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 21.11.2023.
//

import UIKit

final class OCirclePreloaderView: UIView {
    lazy var label = makeLabel()
    
    private lazy var attrs = TextAttributes()
        .textColor(Appearance.black2)
        .font(Fonts.RobotoCondensed.bold(size: 60.scale))
        .lineHeight(70.scale)
        .textAlignment(.center)
    
    private lazy var circleLayer = CAShapeLayer()
    private lazy var trackLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        createCircularPath()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: 226.scale, height: 226.scale)
    }
}

// MARK: Public
extension OCirclePreloaderView {
    func setup(percent: Int) {
        trackLayer.strokeEnd = CGFloat(percent) / 100
        
        let string = String(format: "%i%%", percent)
        label.attributedText = string.attributed(with: attrs)
    }
}

// MARK: Private
private extension OCirclePreloaderView {
    func createCircularPath() {
        let circularPath = UIBezierPath(arcCenter: CGPoint(x: intrinsicContentSize.width / 2,
                                                           y: intrinsicContentSize.height / 2),
                                        radius: (intrinsicContentSize.width - 15.scale) / 2,
                                        startAngle: -.pi / 2,
                                        endAngle: 1.5 * .pi,
                                        clockwise: true)
        circleLayer.path = circularPath.cgPath
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.lineCap = .round
        circleLayer.lineWidth = 15.scale
        circleLayer.strokeStart = 0
        circleLayer.strokeEnd = 1
        circleLayer.strokeColor = Appearance.background2.cgColor
        
        trackLayer.path = circularPath.cgPath
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineCap = .round
        trackLayer.lineWidth = 15.scale
        trackLayer.strokeStart = 0
        trackLayer.strokeEnd = 0
        trackLayer.strokeColor = Appearance.primary1.cgColor

        layer.addSublayer(circleLayer)
        layer.addSublayer(trackLayer)
    }
}

// MARK: Make constraints
private extension OCirclePreloaderView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension OCirclePreloaderView {
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
