//
//  DashboardView.swift
//  MovilCliente (iOS)
//
//  Created by Leonel on 12/06/26.
//

import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel = DashboardViewModel()
    
    // Paleta de Diseño Corporativo "Conecta"
    private let bgMain = Color(red: 245/255, green: 247/255, blue: 250/255)
    private let gradientStart = Color(red: 74/255, green: 144/255, blue: 226/255) // #4A90E2
    private let gradientEnd = Color(red: 0/255, green: 205/255, blue: 184/255)   // #00CDB8
    
    var body: some View {
        ZStack {
            bgMain.ignoresSafeArea()
            
            if viewModel.isLoading && viewModel.services.isEmpty {
                VStack(spacing: 12) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: gradientStart))
                    Text("Cargando información...")
                        .font(.subheadline).foregroundColor(.gray)
                }
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 16) {
                        
                        // MARK: Header Gradiente NAtivo
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Bienvenido a Conecta")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            Text("Tu conexión de fibra óptica de confianza")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(24)
                        .background(
                            LinearGradient(gradient: Gradient(colors: [gradientStart, gradientEnd]), startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .cornerRadius(20)
                        .padding(.horizontal)
                        .padding(.top, 10)
                        
                        // MARK: Card Selector Selector Multicliente
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "bolt.circle.fill")
                                    .foregroundColor(gradientStart).font(.title2)
                                Text("Mis servicios")
                                    .font(.headline).foregroundColor(.primary)
                                Spacer()
                            }
                            
                            Menu {
                                ForEach(viewModel.services) { service in
                                    Button(action: { viewModel.selectedService = service }) {
                                        Text(service.plan?.name ?? "Plan Fibra")
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(viewModel.selectedService?.plan?.name ?? "Sin plan asignado")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(gradientStart)
                                    Image(systemName: "chevron.down")
                                        .font(.caption).foregroundColor(gradientStart)
                                }
                                .padding(.vertical, 4)
                            }
                            .disabled(viewModel.services.count <= 1)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .padding(.horizontal)
                        
                        // MARK: Info Detallada del Plan Activo
                        HStack(spacing: 16) {
                            Image(systemName: "speedometer")
                                .font(.title).foregroundColor(gradientStart)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(viewModel.selectedService?.plan?.name ?? "Sin plan asignado")
                                    .font(.system(size: 16, weight: .bold))
                                Text("Actualizado: Hoy")
                                    .font(.caption).foregroundColor(.gray)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .padding(.horizontal)
                        
                        // MARK: Dirección e Instalación (Simulación de ruteo de Mapas)
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .top, spacing: 16) {
                                Image(systemName: "map.fill")
                                    .font(.title2).foregroundColor(.gray)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(viewModel.selectedService?.addressText ?? "Sin dirección asignada")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.primary)
                                        .fixedSize(horizontal: false, vertical: true)
                                    Text("Dirección de instalación")
                                        .font(.caption).foregroundColor(.gray)
                                }
                                Spacer()
                                if viewModel.selectedService?.latitude != nil {
                                    Image(systemName: "chevron.right")
                                        .font(.footnote).foregroundColor(.gray)
                                }
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .padding(.horizontal)
                        
                        // MARK: Banner de Estado de Cuenta Vencido / Pagos
                        if viewModel.totalPending > 0 {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("¿Pagos pendientes?")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                    Text("Monto acumulado: S/ \(viewModel.totalPending, specifier: "%.2f")")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white.opacity(0.9))
                                }
                                Spacer()
                                Image(systemName: "creditcard.fill")
                                    .font(.title).foregroundColor(.white)
                            }
                            .padding()
                            .background(viewModel.hasOverdueInvoice ? Color.red : gradientStart)
                            .cornerRadius(16)
                            .padding(.horizontal)
                        }
                    }
                }
                .refreshable {
                    await viewModel.loadDashboardData()
                }
            }
            
            // MARK: Overlay de Modal de Alerta de Deuda Crítica
            if viewModel.showDebtModal {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .transition(.opacity)
                
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.red)
                    
                    Text("¡Servicio en Riesgo!")
                        .font(.title2).bold()
                        .foregroundColor(.primary)
                    
                    Text("Tienes una deuda pendiente de **S/\(viewModel.totalPending, specifier: "%.2f")**.\nPor favor regulariza tu pago para evitar el corte del servicio.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    Button(action: { viewModel.showDebtModal = false }) {
                        Text("Entendido")
                            .font(.headline).foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(gradientStart)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 24)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(radius: 20)
                .padding(.horizontal, 36)
                .transition(.scale)
            }
        }
        .onAppear {
            Task { await viewModel.loadDashboardData() }
        }
    }
}

// MARK: - PREVIEW COMPATIBLE CON XCODE 13 PARA DASHBOARDVIEW
struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        // Generamos la instancia de simulación del ViewModel
        let previewModel = DashboardViewModel()
        
        // Creamos estructuras estáticas idénticas a las respuestas JSON de Supabase
        let planPremium = PlanNetworkModel(name: "Fibra Conecta Premium 300 Mbps", downloadSpeed: 300)
        let planBasico = PlanNetworkModel(name: "Conecta Fibra Hogar 100 Mbps", downloadSpeed: 100)
        
        let servicioFicticio1 = ServiceNetworkModel(
            id: "srv_mock_001",
            syncStatus: "synced",
            addressText: "Av. Ejército 405, Yanahuara, Arequipa",
            monthlyAmount: 119.90,
            billingDay: 15,
            lastUispSync: "2026-06-15T10:00:00Z",
            plan: planPremium,
            latitude: -16.409047,
            longitude: -71.537451
        )
        
        let servicioFicticio2 = ServiceNetworkModel(
            id: "srv_mock_002",
            syncStatus: "pending",
            addressText: "Calle Mercaderes 210, Cercado, Arequipa",
            monthlyAmount: 79.90,
            billingDay: 5,
            lastUispSync: nil,
            plan: planBasico,
            latitude: nil,
            longitude: nil
        )
        
        // MARK: - ESCENARIO 1: Vista Normal del Cliente al Día
        // Simulamos que cargó dos servicios y que eligió el plan premium inicialmente
        previewModel.services = [servicioFicticio1, servicioFicticio2]
        previewModel.selectedService = servicioFicticio1
        previewModel.totalPending = 0.0
        previewModel.hasOverdueInvoice = false
        previewModel.showDebtModal = false
        previewModel.isLoading = false
        
        // MARK: - ESCENARIO 2: Alerta Crítica de Deuda (Servicio en Riesgo)
        let alertModel = DashboardViewModel()
        alertModel.services = [servicioFicticio1]
        alertModel.selectedService = servicioFicticio1
        alertModel.totalPending = 189.50
        alertModel.hasOverdueInvoice = true
        alertModel.showDebtModal = true // Forzamos a que el pop-up rojo se pinte en el canvas
        alertModel.isLoading = false

        return Group {
            DashboardView()
                .environmentObject(previewModel)
                .preferredColorScheme(.light)
                .previewDisplayName("Dashboard Cuenta Ok")
            
            DashboardView()
                .environmentObject(alertModel)
                .preferredColorScheme(.light)
                .previewDisplayName("Dashboard Cuenta Vencida")
        }
    }
}
