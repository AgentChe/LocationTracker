//
//  ChatManager.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 07.02.2024.
//

import RxSwift
import Starscream

protocol ChatManagerProtocol {
    func connect()
    func disconnect()
    func action(action: ChatManager.Action)
    var event: Observable<SocketEvent<ChatEvent>> { get }
}

final class ChatManager {
    enum Action {
        case getList(Int)
        case sendMessage(String)
    }
    
    private lazy var mapper = ChatEventMapper()
    private let socket: WebSocket
    
    init(partnerId: String) {
        let userId = ProfileManager().chatId ?? ""
        let path = String(
            format: "%@/ws/chat/%@?user=%@&app_key=%@",
            GlobalDefinitions.chatHost, partnerId, userId, GlobalDefinitions.chatAppKey
        )
        let url = URL(string: path)!
        let request = URLRequest(url: url)
        socket = WebSocket(request: request)
    }
}

// MARK: ChatManagerProtocol
extension ChatManager: ChatManagerProtocol {
    func connect() {
        socket.forceDisconnect()
        socket.connect()
    }
    
    func disconnect() {
        socket.disconnect()
    }
    
    func action(action: ChatManager.Action) {
        let json: [String: Any]
        
        switch action {
        case .getList(let page):
            json = ["action": "get_list", "page": page]
        case .sendMessage(let body):
            let utf8 = body.utf8_encoded ?? body
            json = ["action": "send_message", "body": utf8]
        }
        
        guard let jsonString = json.jsonString() else {
            return
        }
        
        socket.write(string: jsonString)
    }
    
    var event: Observable<SocketEvent<ChatEvent>> {
        Observable<SocketEvent<ChatEvent>>.create { [weak self] observer in
            guard let self else {
                return Disposables.create()
            }
            
            self.socket.onEvent = { event in
                switch event {
                case .connected:
                    observer.onNext(.connected)
                case .text(let string):
                    if let chatEvent = self.mapper.map(from: string) {
                        observer.on(.next(.event(chatEvent)))
                    }
                case .error(let error):
                    observer.on(.next(.error(error ?? NSError(domain: "Chats.PeerClosed".localized, code: 500))))
                case .peerClosed:
                    observer.on(.next(.peerClosed))
                default:
                    break
                }
            }
            
            return Disposables.create {
                self.disconnect()
            }
        }
    }
}
