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
            
            // Pestaña 4: Facturación y Pagos - SwiftUI
            NavigationView {
                Text("Historial de Facturas")
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

// Representable provisional para soporte de compilación cruzada UIKit
struct TicketsViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let container = UIViewController()
        container.view.backgroundColor = .systemBackground
        let label = UILabel()
        label.text = "Módulo de Tickets (UIKit)"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        container.view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: container.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: container.view.centerYAnchor)
        ])
        return container
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
