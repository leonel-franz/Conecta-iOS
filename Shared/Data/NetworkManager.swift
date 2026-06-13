//
//  NetworkManager.swift
//  MovilCliente (iOS)
//
//  Created by Leonel on 12/06/26.
//

import Foundation

// MARK: - Errores de Red Personalizados
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case serverError(String)
    case unauthorized
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "La URL configurada no es válida."
        case .noData: return "El servidor no retornó datos."
        case .decodingError: return "Error al procesar la respuesta del servidor."
        case .serverError(let msg): return msg
        case .unauthorized: return "Sesión expirada o credenciales incorrectas."
        }
    }
}

// MARK: - Manager Central de Conectividad (Singleton)
class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    /// Autentica al usuario y obtiene el Token de sesión inicial
    func login(credentials: [String: String]) async throws -> LoginNetworkModelResponse {
        guard let url = URL(string: AppConfig.Endpoints.login) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: credentials)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.noData
        }
        
        if httpResponse.statusCode == 401 {
            throw NetworkError.unauthorized
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError("Error del servidor: Código \(httpResponse.statusCode)")
        }
        
        do {
            return try JSONDecoder().decode(LoginNetworkModelResponse.self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }
    
    /// Obtiene los datos del perfil del cliente actual
    func getCustomerProfile(token: String) async throws -> CustomerProfileNetworkModel {
        guard let url = URL(string: AppConfig.Endpoints.profile) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.noData
        }
        
        if httpResponse.statusCode == 401 {
            throw NetworkError.unauthorized
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError("Error al recuperar el perfil.")
        }
        
        do {
            return try JSONDecoder().decode(CustomerProfileNetworkModel.self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }
    
    /// Consume el resumen de deudas vigentes asociadas al usuario autenticado
    func getMyDebts(token: String) async throws -> DebtSummaryNetworkModel {
        guard let url = URL(string: AppConfig.Endpoints.invoices) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError("Error al recuperar deudas.")
        }
        
        do {
            let container = try JSONDecoder().decode(APIResponseContainer<DebtSummaryNetworkModel>.self, from: data)
            guard let summary = container.data else { throw NetworkError.noData }
            return summary
        } catch {
            throw NetworkError.decodingError
        }
    }
    
    /// Recupera la colección completa de contratos y servicios del cliente
    func getMyServices(token: String) async throws -> [ServiceNetworkModel] {
        guard let url = URL(string: AppConfig.Endpoints.services) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError("Error al recuperar servicios.")
        }
        
        // Manejo adaptativo flex-parsing (Direct Array o Envuelto en objeto JSON)
        if let container = try? JSONDecoder().decode(APIResponseContainer<[ServiceNetworkModel]>.self, from: data), let list = container.data {
            return list
        }
        if let rawList = try? JSONDecoder().decode([ServiceNetworkModel].self, from: data) {
            return rawList
        }
        throw NetworkError.decodingError
    }
}
