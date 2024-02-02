//
//  SocketEvent.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 02.02.2024.
//

enum SocketEvent<V> {
    case connected
    case error(Error)
    case peerClosed
    case event(V)
}
