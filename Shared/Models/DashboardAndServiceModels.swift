//
//  DashboardAndServiceModels.swift
//  MovilCliente (iOS)
//
//  Created by Leonel on 12/06/26.
//

import Foundation

// MARK: - Modelos de Plan y Servicio
struct PlanNetworkModel: Decodable, Equatable {
    let id: String?
    let name: String?
}

struct ServiceNetworkModel: Decodable, Identifiable, Equatable {
    let id: String
    let status: String? // synced, ok, pending, error
    let addressText: String?
    let latitude: Double?
    let longitude: Double?
    let plan: PlanNetworkModel?
    
    enum CodingKeys: String, CodingKey {
        case id
        case status
        case addressText = "address_text"
        case latitude
        case longitude
        case plan
    }
}

// MARK: - Modelos de Facturación y Deuda
struct InvoiceNetworkModel: Decodable, Identifiable, Equatable {
    let id: String
    let status: String? // pending, paid
    let dueDate: String? // ISO String
    let total: Double?
    
    enum CodingKeys: String, CodingKey {
        case id
        case status
        case dueDate = "due_date"
        case total
    }
}

struct DebtSummaryNetworkModel: Decodable {
    let totalPending: Double?
    let items: [InvoiceNetworkModel]?
    
    enum CodingKeys: String, CodingKey {
        case totalPending = "totalPending"
        case items
    }
}

// MARK: - Contenedor Genérico de Respuestas de API (Axios wrapper fallback)
struct APIResponseContainer<T: Decodable>: Decodable {
    let data: T?
}
