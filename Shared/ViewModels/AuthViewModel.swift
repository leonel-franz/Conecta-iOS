//
//  AuthViewModel.swift
//  MovilCliente (iOS)
//
//  Created by Leonel on 12/06/26.
//

import Foundation
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var user: UserNetworkModel? = nil
    @Published var isLoading: Bool = false
    @Published var isAuthenticated: Bool = false
    @Published var errorMessage: String? = nil
    
    private let tokenKey = "access_token"
    private let userKey = "stored_user"
    
    init() {
        checkExistingSession()
    }
    
    func checkExistingSession() {
        self.isLoading = true
        let token = UserDefaults.standard.string(forKey: tokenKey)
        if let userData = UserDefaults.standard.data(forKey: userKey), token != nil {
            do {
                let decodedUser = try JSONDecoder().decode(UserNetworkModel.self, from: userData)
                self.user = decodedUser
                self.isAuthenticated = true
            } catch {
                self.logout()
            }
        }
        self.isLoading = false
    }
    
    func login(email: String, password: String) async {
        self.isLoading = true
        self.errorMessage = nil
        let credentials = ["email": email, "password": password]
        
        do {
            let response = try await NetworkManager.shared.login(credentials: credentials)
            UserDefaults.standard.set(response.accessToken, forKey: tokenKey)
            if let encodedUser = try? JSONEncoder().encode(response.user) {
                UserDefaults.standard.set(encodedUser, forKey: userKey)
            }
            self.user = response.user
            self.isAuthenticated = true
        } catch let error as NetworkError {
            self.errorMessage = error.localizedDescription
        } catch {
            self.errorMessage = "Ocurrió un error inesperado al iniciar sesión."
        }
        self.isLoading = false
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
        UserDefaults.standard.removeObject(forKey: userKey)
        self.user = nil
        self.isAuthenticated = false
        self.errorMessage = nil
    }
}
