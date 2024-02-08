//
//  ChatsManager.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 01.02.2024.
//

import RxSwift
import Starscream

protocol ChatsManagerProtocol {
    func connect()
    func disconnect()
    func action(action: ChatsManager.Action)
    var event: Observable<SocketEvent<ChatsEvent>> { get }
}

final class ChatsManager {
    enum Action {
        case getList
        case remove(String)
    }
    
    private lazy var mapper = ChatsEventsMapper()
    private let socket: WebSocket
    
    init() {
        let userId = SessionManager().userId
        let path = String(
            format: "%@/ws/chats?user=%@&app_key=%@",
            GlobalDefinitions.chatHost, userId, GlobalDefinitions.chatAppKey
        )
        let url = URL(string: path)!
        let request = URLRequest(url: url)
        socket = WebSocket(request: request)
    }
}

// MARK: ChatsManagerProtocol
extension ChatsManager: ChatsManagerProtocol {
    func connect() {
        socket.forceDisconnect()
        socket.connect()
    }
    
    func disconnect() {
        socket.disconnect()
    }
    
    func action(action: ChatsManager.Action) {
        let json: [String: Any]
        
        switch action {
        case .getList:
            json = ["action": "get_list"]
        case .remove(let id):
            json = ["action": "remove", "id": id]
        }
        
        guard let jsonString = json.jsonString() else {
            return
        }
        
        socket.write(string: jsonString)
    }
    
    var event: Observable<SocketEvent<ChatsEvent>> {
        Observable<SocketEvent<ChatsEvent>>.create { [weak self] observer in
            guard let self else {
                return Disposables.create()
            }
            
            self.socket.onEvent = { event in
                switch event {
                case .connected:
                    observer.onNext(.connected)
                case .text(let string):
                    if let chatsEvent = self.mapper.map(from: string) {
                        observer.on(.next(.event(chatsEvent)))
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
