//
//  ServiciosViewModel.swift
//  MovilCliente
//
//  Created by Leonel on 12/06/26.
//

import Foundation
import Combine

@MainActor
class ServiciosViewModel: ObservableObject {
    @Published var services: [ServiceNetworkModel] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    func fetchServices() async {
        self.isLoading = true
        self.errorMessage = nil
        
        guard let token = UserDefaults.standard.string(forKey: "access_token") else {
            self.errorMessage = "Autenticación requerida."
            self.isLoading = false
            return
        }
        
        do {
            self.services = try await NetworkManager.shared.getMyServices(token: token)
        } catch let error as NetworkError {
            self.errorMessage = error.localizedDescription
        } catch {
            self.errorMessage = "Ocurrió un error al procesar los datos."
        }
        self.isLoading = false
    }
}
