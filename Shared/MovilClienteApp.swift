//
//  MovilClienteApp.swift
//  Shared
//
//  Created by Leonel on 12/06/26.
//

import SwiftUI

@main
struct MovilClienteApp: App {
    // 1. Inicialización del contenedor persistente de Core Data provisto por Xcode 13 por defecto
    let persistenceController = PersistenceController.shared
    
    // 2. Instancia única y global del ViewModel de Autenticación para controlar la sesión
    @StateObject private var authViewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            // 3. Evaluación reactiva del estado de autenticación
            if authViewModel.isAuthenticated {
                // Si el usuario ya está logueado, se despliega la interfaz de pestañas principal de Conecta
                MainTabView()
                    // Inyectamos el ViewModel como EnvironmentObject para que todas las pestañas de SwiftUI
                    // y los puentes de UIKit puedan consultar el usuario actual o disparar el logout()
                    .environmentObject(authViewModel)
                    // Inyectamos el contexto de base de datos local por si alguna pestaña requiere persistencia
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            } else {
                // Si no hay sesión activa en UserDefaults, se fuerza la vista de inicio de sesión
                LoginView()
            }
        }
    }
}
