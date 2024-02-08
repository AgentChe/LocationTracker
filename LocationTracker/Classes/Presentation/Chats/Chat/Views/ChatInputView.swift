//
//  ChatInputView.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 08.02.2024.
//

import UIKit
import Kingfisher

final class ChatInputView: UIView {
    var didTapSend: ((String) -> Void)?
    
    lazy var container = makeContainer()
    lazy var imageView = makeImageView()
    lazy var placeholderNameLabel = makeLabel()
    lazy var textField = makeTextField()
    lazy var sendButton = makeSendButton()
    
    private lazy var placeholderNameAttrs = TextAttributes()
        .textColor(Appearance.primary1)
        .font(Fonts.RobotoCondensed.bold(size: 16.scale))
        .lineHeight(22.4.scale)
        .textAlignment(.center)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
        initialize()
        textEdited()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension ChatInputView {
    func setup(partner: ChatViewModel.Partner) {
        placeholderNameLabel.isHidden = partner.photoURL != nil

        if let url = partner.photoURL {
            imageView.kf.setImage(with: url)
        } else if let firstCharacter = partner.name.first {
            let string = String(firstCharacter)
            placeholderNameLabel.attributedText = string.attributed(with: placeholderNameAttrs)
        }
    }
}

// MARK: UITextFieldDelegate
extension ChatInputView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMessage()
        
        textField.resignFirstResponder()
        
        return true
    }
}

// MARK: Private
private extension ChatInputView {
    func initialize() {
        backgroundColor = UIColor.clear
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    @objc
    func textEdited() {
        let sendHidden = (textField.text ?? "").isEmpty
        sendButton.isHidden = sendHidden
    }
    
    @objc
    func sendTapped() {
        sendMessage()
    }
    
    func sendMessage() {
        let message = (textField.text ?? "")
        
        guard !message.isEmpty else {
            return
        }
        
        didTapSend?(message)
        
        textField.text = ""
        
        textEdited()
    }
}

// MARK: Make constraints
private extension ChatInputView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            container.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            container.topAnchor.constraint(equalTo: topAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor),
            container.heightAnchor.constraint(equalToConstant: 48.scale)
        ])
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 40.scale),
            imageView.heightAnchor.constraint(equalToConstant: 40.scale),
            imageView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8.scale),
            imageView.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            placeholderNameLabel.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            placeholderNameLabel.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 8.scale),
            textField.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -56.scale),
            textField.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            sendButton.widthAnchor.constraint(equalToConstant: 48.scale),
            sendButton.heightAnchor.constraint(equalToConstant: 48.scale),
            sendButton.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            sendButton.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension ChatInputView {
    func makeContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.white
        view.layer.borderColor = Appearance.background2.cgColor
        view.layer.borderWidth = 1.scale
        view.layer.cornerRadius = 20.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.backgroundColor = Appearance.primary2
        view.layer.cornerRadius = 20.scale
        view.layer.masksToBounds = true
        view.layer.borderColor = Appearance.background2.cgColor
        view.layer.borderWidth = 1.scale
        view.contentMode = .scaleAspectFill
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeTextField() -> PaddingTextField {
        let placeholderAttrs = TextAttributes()
            .textColor(Appearance.black2.withAlphaComponent(0.4))
            .font(Fonts.RobotoCondensed.regular(size: 16.scale))
            .lineHeight(22.4.scale)
        let textAttrs = TextAttributes()
            .textColor(Appearance.black2)
            .font(Fonts.RobotoCondensed.regular(size: 16.scale))
            .lineHeight(22.4.scale)
        
        let view = PaddingTextField()
        view.textPadding = UIEdgeInsets(vertical: 16.scale)
        view.attributedPlaceholder = "Chat.Input.Placeholder".localized.attributed(with: placeholderAttrs)
        view.defaultTextAttributes = textAttrs.dictionary
        view.delegate = self
        view.returnKeyType = .done
        view.backgroundColor = UIColor.clear
        view.addTarget(self, action: #selector(textEdited), for: .editingChanged)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeSendButton() -> TapAreaButton {
        let view = TapAreaButton()
        view.setImage(UIImage(named: "Chat.Send"), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
        container.addSubview(view)
        return view
    }
}
