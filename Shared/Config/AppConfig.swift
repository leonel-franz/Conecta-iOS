//
//  AppConfig.swift
//  MovilCliente
//
//  Created by Leonel on 12/06/26.
//

import Foundation

struct AppConfig {
    // REEMPLAZA esta IP por la IP local de tu máquina donde corre el backend de Conecta.
    // AGREGAMOS "/api" al final, ya que todas las rutas de tu servidor Node.js están protegidas bajo ese prefijo.
    static let baseURL = "http://192.168.1.50:3000/api"
    
    struct Endpoints {
        static let login = "\(AppConfig.baseURL)/auth/login"
        static let signup = "\(AppConfig.baseURL)/auth/signup-client"
        static let profile = "\(AppConfig.baseURL)/customers/me"
        
        // Rutas secundarias corregidas con el prefijo /api automático
        static let services = "\(AppConfig.baseURL)/services/my-services"
        static let tickets = "\(AppConfig.baseURL)/tickets"
        static let invoices = "\(AppConfig.baseURL)/invoices/my-debts"
    }
}
