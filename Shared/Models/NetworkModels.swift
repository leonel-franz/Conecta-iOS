//
//  NetworkModels.swift
//  MovilCliente
//
//  Created by Leonel on 12/06/26.
//

import Foundation

// MARK: - 1. CAPA DE AUTENTICACIÓN Y USUARIO
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

struct LoginNetworkModelResponse: Codable {
    let accessToken: String
    let user: UserNetworkModel
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case user
    }
}

// CORREGIDO: Añadidos los campos extendidos requeridos para el perfil en vivo de Conecta
struct CustomerProfileNetworkModel: Codable {
    let id: String
    let fullName: String
    let email: String
    let phone: String?
    let documentType: String?
    let documentNumber: String?
    let billingDocumentType: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case fullName = "full_name"
        case email
        case phone
        case documentType = "document_type"
        case documentNumber = "document_number"
        case billingDocumentType = "billing_document_type"
    }
}

// MARK: - 2. CAPA DE SERVICIOS Y PLANES DE INTERNET
struct PlanNetworkModel: Codable, Equatable {
    let name: String
    let downloadSpeed: Int
    
    enum CodingKeys: String, CodingKey {
        case name
        case downloadSpeed = "download_speed"
    }
}

struct ServiceNetworkModel: Codable, Identifiable, Equatable {
    let id: String
    let syncStatus: String
    let addressText: String?
    let monthlyAmount: Double
    let billingDay: Int
    let lastUispSync: String?
    let plan: PlanNetworkModel?
    
    // Propiedades de mapa requeridas por el Dashboard
    let latitude: Double?
    let longitude: Double?
    
    enum CodingKeys: String, CodingKey {
        case id
        case syncStatus = "sync_status"
        case addressText = "address_text"
        case monthlyAmount = "monthly_amount"
        case billingDay = "billing_day"
        case lastUispSync = "last_uisp_sync"
        case plan
        case latitude
        case longitude
    }
    
    // Propiedad calculada de compatibilidad para el Dashboard antiguo
    var status: String? {
        return syncStatus
    }
}

// MARK: - 3. CAPA DE FACTURACIÓN Y DEUDAS
struct InvoiceNetworkModel: Codable, Identifiable, Equatable {
    let id: String
    let status: String?
    let dueDate: String?
    let total: Double?
    
    enum CodingKeys: String, CodingKey {
        case id
        case status
        case dueDate = "due_date"
        case total
    }
}

struct DebtSummaryNetworkModel: Codable {
    let totalPending: Double?
    let items: [InvoiceNetworkModel]?
    
    enum CodingKeys: String, CodingKey {
        case totalPending
        case items
    }
}

// MARK: - 4. CONTENEDOR DE RESPUESTA GENÉRICO API
struct APIResponseContainer<T: Codable>: Codable {
    let data: T?
}
