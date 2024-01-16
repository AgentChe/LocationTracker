//
//  SOSInstructionView.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 16.01.2024.
//

import UIKit

final class SOSInstructionView: UIView {
    lazy var scrollView = makeScrollView()
    lazy var imageView = makeImageView()
    lazy var titleLabel = makeTitleLabel()
    lazy var subTitleLabel = makeSubTitleLabel()
    lazy var block1View = makeBlock1View()
    lazy var block2View = makeBlock2View()
    lazy var block3View = makeBlock3View()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension SOSInstructionView {
    func initialize() {
        backgroundColor = Appearance.background1
    }
}

// MARK: Make constraints
private extension SOSInstructionView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 343.scale),
            imageView.heightAnchor.constraint(equalToConstant: 191.scale),
            imageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 27.scale)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            titleLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16.scale),
            titleLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16.scale),
            titleLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 244.scale)
        ])
        
        NSLayoutConstraint.activate([
            subTitleLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16.scale),
            subTitleLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16.scale),
            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4.scale)
        ])
        
        NSLayoutConstraint.activate([
            block1View.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            block1View.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            block1View.topAnchor.constraint(equalTo: subTitleLabel.bottomAnchor, constant: 26.scale)
        ])
        
        NSLayoutConstraint.activate([
            block2View.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            block2View.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            block2View.topAnchor.constraint(equalTo: block1View.bottomAnchor, constant: 16.scale)
        ])
        
        NSLayoutConstraint.activate([
            block3View.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            block3View.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            block3View.topAnchor.constraint(equalTo: block2View.bottomAnchor, constant: 16.scale),
            block3View.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -92.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension SOSInstructionView {
    func makeScrollView() -> UIScrollView {
        let view = UIScrollView()
        view.backgroundColor = UIColor.clear
        view.showsVerticalScrollIndicator = false
        view.contentInset = UIEdgeInsets.zero
        view.setContentOffset(CGPoint.zero, animated: false)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        view.image = UIImage(named: "Onboarding.SOSInstruction1")
        view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(view)
        return view
    }
    
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.black2)
            .font(Fonts.RobotoCondensed.medium(size: 32.scale))
            .lineHeight(44.8.scale)
            .textAlignment(.left)
        
        let view = UILabel()
        view.attributedText = "Onboarding.SOSInstruction.Title".localized.attributed(with: attrs)
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(view)
        return view
    }
    
    func makeSubTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.black1)
            .font(Fonts.RobotoCondensed.regular(size: 16.scale))
            .lineHeight(22.4.scale)
            .textAlignment(.left)
        
        let view = UILabel()
        view.attributedText = "Onboarding.SOSInstruction.SubTitle".localized.attributed(with: attrs)
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(view)
        return view
    }
    
    func makeBlock1View() -> SOSInstructionBlockView {
        let view = SOSInstructionBlockView(
            imageName: "Onboarding.SOSInstruction2",
            text: "Onboarding.SOSInstruction.Block1".localized
        )
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(view)
        return view
    }
    
    func makeBlock2View() -> SOSInstructionBlockView {
        let view = SOSInstructionBlockView(
            imageName: "Onboarding.SOSInstruction3",
            text: "Onboarding.SOSInstruction.Block2".localized
        )
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(view)
        return view
    }
    
    func makeBlock3View() -> SOSInstructionBlockView {
        let view = SOSInstructionBlockView(
            imageName: "Onboarding.SOSInstruction4",
            text: "Onboarding.SOSInstruction.Block3".localized
        )
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(view)
        return view
    }
}
