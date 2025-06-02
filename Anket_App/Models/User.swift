//
//  User.swift
//  Anket_App
//
//  Created by zehra özer on 18.05.2025.
//

import Foundation

struct User: Codable, CustomStringConvertible {
    let mail: String
    let password: String
    
    var description: String {
        return "User(mail: \(mail), password: ***)"
    }
}
