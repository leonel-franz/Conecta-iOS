//
//  DashboardViewModel.swift
//  MovilCliente (iOS)
//
//  Created by Leonel on 12/06/26.
//

import Foundation
import Combine

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var services: [ServiceNetworkModel] = []
    @Published var selectedService: ServiceNetworkModel? = nil
    @Published var totalPending: Double = 0.0
    @Published var hasOverdueInvoice: Bool = false
    
    @Published var isLoading: Bool = false
    @Published var showDebtModal: Bool = false
    @Published var errorMessage: String? = nil
    
    func loadDashboardData() async {
        self.isLoading = true
        self.errorMessage = nil
        
        // Extraemos de forma segura el token guardado en UserDefaults
        guard let token = UserDefaults.standard.string(forKey: "access_token") else {
            self.errorMessage = "Sesión no válida"
            self.isLoading = false
            return
        }
        
        do {
            // Ejecución concurrente estructurada (Equivalente a Promise.all de RN)
            async let debtsFetch = NetworkManager.shared.getMyDebts(token: token)
            async let servicesFetch = NetworkManager.shared.getMyServices(token: token)
            
            let debtSummary = try await debtsFetch
            let fetchedServices = try await servicesFetch
            
            self.services = fetchedServices
            if !services.isEmpty && self.selectedService == nil {
                self.selectedService = services.first
            }
            
            self.totalPending = debtSummary.totalPending ?? 0.0
            let items = debtSummary.items ?? []
            
            // Validación de facturas vencidas (Mapeo de date-fns/isPast)
            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            let now = Date()
            
            self.hasOverdueInvoice = items.contains { invoice in
                guard invoice.status == "pending", let dateStr = invoice.dueDate else { return false }
                // Soporte para variaciones de formato de fecha ISO
                let formattedDate = isoFormatter.date(from: dateStr) ?? DateFormatter.iso8601Fallback(from: dateStr)
                return formattedDate < now
            }
            
            if self.hasOverdueInvoice && self.totalPending > 0 {
                self.showDebtModal = true
            }
            
        } catch let error as NetworkError {
            self.errorMessage = error.localizedDescription
        } catch {
            self.errorMessage = "Error de sincronización con Conecta."
        }
        
        self.isLoading = false
    }
    
    func selectService(id: String) {
        if let matched = services.first(where: { $0.id == id }) {
            self.selectedService = matched
        }
    }
}

// Extensión auxiliar de sanitización de fechas ISO para Xcode 13 / iOS 15
extension DateFormatter {
    static func iso8601Fallback(from string: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter.date(from: string) ?? Date()
    }
}
