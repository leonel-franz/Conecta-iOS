//
//  NetworkModels.swift
//  MovilCliente (iOS)
//
//  Created by Leonel on 12/06/26.
//

import Foundation

// Representa el objeto de usuario de la plataforma Conecta
struct UserNetworkModel: Codable, Equatable {
    let id: String
    let email: String
    let role: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case role
    }
}

// Estructura para mapear la respuesta del login
struct LoginNetworkModelResponse: Codable {
    let accessToken: String
    let user: UserNetworkModel
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case user
    }
}

// Estructura para el perfil del cliente
struct CustomerProfileNetworkModel: Codable {
    let id: String
    let fullName: String
    let email: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case fullName = "full_name"
        case email
    }
}
