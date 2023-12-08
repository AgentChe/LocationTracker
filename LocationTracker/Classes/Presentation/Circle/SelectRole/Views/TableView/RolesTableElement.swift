//
//  RolesTableElement.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 07.12.2023.
//

final class RolesTableElement {
    let role: Role
    var marked: Bool
    
    init(role: Role, marked: Bool) {
        self.role = role
        self.marked = marked
    }
}
