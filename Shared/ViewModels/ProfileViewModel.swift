//
//  ProfileViewModel.swift
//  MovilCliente
//
//  Created by Leonel on 15/06/26.
//

import Foundation
import Combine

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var profile: CustomerProfileNetworkModel? = nil
    @Published var services: [ServiceNetworkModel] = []
    @Published var isLoading: Bool = false
    @Published var isRefetching: Bool = false
    @Published var servicesLoading: Bool = false
    @Published var isMutationPending: Bool = false
    @Published var errorMessage: String? = nil
    @Published var alertMessage: (title: String, message: String)? = nil
    
    @Published var isEditing: Bool = false
    @Published var phone: String = ""
    @Published var documentType: String = ""
    @Published var documentNumber: String = ""
    @Published var billingType: String = ""
    @Published var showServices: Bool = false
    
    func loadProfileData() async {
        self.isLoading = true
        await refetchAll()
        self.isLoading = false
    }
    
    func refetchAll() async {
        guard let token = UserDefaults.standard.string(forKey: "access_token") else {
            self.errorMessage = "Autenticación requerida."
            return
        }
        
        self.isRefetching = true
        self.servicesLoading = true
        
        do {
            async let fetchedProfile = NetworkManager.shared.getCustomerProfile(token: token)
            async let fetchedServices = NetworkManager.shared.getMyServices(token: token)
            
            self.profile = try await fetchedProfile
            self.services = try await fetchedServices
        } catch {
            self.errorMessage = "No se pudo conectar al servidor de Conecta."
        }
        
        self.isRefetching = false
        self.servicesLoading = false
    }
    
    func handleEdit() {
        guard let currentProfile = profile else { return }
        self.phone = currentProfile.phone ?? ""
        let dt = (currentProfile.documentType ?? "").uppercased()
        self.documentType = (dt == "RUC" || dt == "DNI") ? dt : ""
        let rawDoc = (currentProfile.documentNumber ?? "").components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        let maxLen = (self.documentType == "RUC") ? 11 : 8
        self.documentNumber = String(rawDoc.prefix(maxLen))
        let bt = (currentProfile.billingDocumentType ?? "").uppercased()
        self.billingType = (bt == "FACTURA") ? "Factura" : (bt == "BOLETA" ? "Boleta" : "")
        self.isEditing = true
    }
    
    func handleCancel() {
        self.isEditing = false
        self.phone = ""
        self.documentType = ""
        self.documentNumber = ""
        self.billingType = ""
    }
    
    func handleDocumentNumberChange(_ newValue: String) {
        let filtered = newValue.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        let maxLen = (documentType == "RUC") ? 11 : 8
        self.documentNumber = String(filtered.prefix(maxLen))
    }
    
    func handleDocumentTypeSelect(_ type: String) {
        self.documentType = type
        let maxLen = (type == "RUC") ? 11 : 8
        self.documentNumber = String(documentNumber.prefix(maxLen))
    }
    
    func handleSave() async {
        guard let currentProfile = profile, let token = UserDefaults.standard.string(forKey: "access_token") else { return }
        self.isMutationPending = true
        
        let apiBillingType = (billingType == "Factura") ? "FACTURA" : ((billingType == "Boleta") ? "BOLETA" : "")
        let payload: [String: Any] = [
            "id": currentProfile.id,
            "phone": phone,
            "document_number": documentNumber,
            "document_type": documentType,
            "billing_document_type": apiBillingType
        ]
        
        do {
            guard let url = URL(string: "\(AppConfig.baseURL)/customers/\(currentProfile.id)") else { throw NetworkError.invalidURL }
            var request = URLRequest(url: url)
            request.httpMethod = "PATCH"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            // CORRECCIÓN TÉCNICA: Serialización directa y limpia compatible con URLSession
            request.httpBody = try? JSONSerialization.data(withJSONObject: payload, options: [])
            
            let (_, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                await refetchAll()
                self.isEditing = false
                self.alertMessage = (title: "Perfil actualizado", message: "Tus datos han sido guardados correctamente")
            } else {
                self.alertMessage = (title: "Error", message: "No se pudo actualizar el perfil.")
            }
        } catch {
            self.alertMessage = (title: "Error", message: error.localizedDescription)
        }
        self.isMutationPending = false
    }
    
    func getStatusLabel(status: String?) -> String {
        guard let status = status else { return "—" }
        switch status {
        case "active", "synced", "ok": return "Activo"
        case "pending": return "Pendiente"
        case "suspended": return "Suspendido"
        default: return status
        }
    }
}
