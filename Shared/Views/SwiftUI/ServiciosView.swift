//
//  ServiciosView.swift
//  MovilCliente (iOS)
//
//  Created by Leonel on 12/06/26.
//

import SwiftUI

struct ServiciosView: View {
    @StateObject private var viewModel = ServiciosViewModel()
    private let primaryBlue = Color(red: 74/255, green: 144/255, blue: 226/255)
    
    var body: some View {
        ZStack {
            Color(red: 245/255, green: 247/255, blue: 250/255).ignoresSafeArea()
            
            if viewModel.isLoading && viewModel.services.isEmpty {
                ProgressView("Cargando tus servicios...")
            } else if viewModel.services.isEmpty {
                // MARK: Estado Vacío Nativo
                VStack(spacing: 16) {
                    Text("○")
                        .font(.system(size: 60, weight: .light))
                        .foregroundColor(.gray)
                    Text("Sin servicios activos")
                        .font(.headline).foregroundColor(.primary)
                    Text(viewModel.errorMessage != nil ? "Error al cargar servicios. Intenta nuevamente." : "Si acabas de contratar un plan, puede\ntardar unos minutos en aparecer aquí")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 16) {
                        ForEach(viewModel.services) { service in
                            ServiceCardComponent(service: service)
                        }
                        
                        // MARK: Cuadro de Información Adicional Inferior
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Información importante")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.primary)
                            Text("El estado de sincronización muestra la conexión en tiempo real con tu antena. Si experimentas problemas de conexión, verifica el estado aquí antes de contactar soporte.")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    .padding(.top, 12)
                }
                .refreshable {
                    await viewModel.fetchServices()
                }
            }
        }
        .onAppear {
            Task { await viewModel.fetchServices() }
        }
    }
}

// MARK: - Componente Reutilizable Interno: ServiceCard
struct ServiceCardComponent: View {
    let service: ServiceNetworkModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(service.plan?.name ?? "Plan Conecta Fibra")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                Spacer()
                
                // Mapeo Dinámico de Badges e Identificadores de Sincronización
                let badge = getSyncBadge(service.status ?? "")
                Text(badge.label)
                    .font(.system(size: 12, weight: .bold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(badge.bgColor)
                    .foregroundColor(badge.color)
                    .cornerRadius(8)
            }
            
            Text(service.addressText ?? "Sin dirección registrada")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.02), radius: 6, x: 0, y: 3)
        .padding(.horizontal)
    }
    
    // Helper de mapeo de estilos visuales basados en código de estado
    private func getSyncBadge(_ status: String) -> (label: String, color: Color, bgColor: Color) {
        switch status {
        case "synced", "ok":
            return ("Activo", .green, Color.green.opacity(0.1))
        case "pending":
            return ("Pendiente", .orange, Color.orange.opacity(0.1))
        case "error":
            return ("Error", .red, Color.red.opacity(0.1))
        default:
            return ("Inactivo", .gray, Color.gray.opacity(0.1))
        }
    }
}
