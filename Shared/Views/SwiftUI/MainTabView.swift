//
//  MainTabView.swift
//  MovilCliente
//
//  Created by Leonel on 12/06/26.
//

//
//  MainTabView.swift
//  MovilCliente
//
//  Created by Leonel on 12/06/26.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedTab = 0
    
    // Configuración de color corporativo Conecta
    private let primaryColor = Color(red: 0.17, green: 0.62, blue: 0.70) // #2B9EB3
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Pestaña 1: Inicio (Dashboard) - SwiftUI
            NavigationView {
                DashboardView() // Enlazado con tu Dashboard nativo
                    .navigationTitle("Inicio")
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Inicio")
            }
            .tag(0)
            
            // Pestaña 2: Servicios contratados - SwiftUI (REEMPLAZADO COMPLETO)
            NavigationView {
                ServiciosView()
                    .navigationTitle("Mis Servicios")
            }
            .tabItem {
                Image(systemName: "bolt.fill")
                Text("Servicios")
            }
            .tag(1)
            
            // Pestaña 3: Solicitudes (Tickets) - Híbrido UIKit obligatorio
            NavigationView {
                // Llama al puente independiente conectado a tu tabla real de UIKit
                TicketsViewControllerRepresentable()
                    .edgesIgnoringSafeArea(.top)
                    .navigationTitle("Soporte")
                    .navigationBarHidden(true)
            }
            .tabItem {
                Image(systemName: "ticket.fill")
                Text("Soporte")
            }
            .tag(2)
            
            // Pestaña 4: Facturación y Pagos - SwiftUI (MIGRADO DE TU PAGOSSCREEN)
            NavigationView {
                PagosView() // Enlazado con tu pasarela y visor de recibos nativo
                    .navigationTitle("Pagos")
            }
            .tabItem {
                Image(systemName: "creditcard.fill")
                Text("Pagos")
            }
            .tag(3)
        }
        .accentColor(primaryColor)
    }
}

// MARK: - PREVIEW OFICIAL PARA MAINTABVIEW
struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        let authMock = AuthViewModel()
        authMock.isAuthenticated = true
        
        return MainTabView()
            .environmentObject(authMock)
            .previewDisplayName("Navegación por Pestañas (Tabs)")
    }
}
