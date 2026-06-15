//
//  ServiciosView.swift
//  MovilCliente
//
//  Created by Leonel on 12/06/26.
//

import SwiftUI

struct ServiciosView: View {
    @StateObject private var viewModel = ServiciosViewModel()
    
    var body: some View {
        ZStack {
            // Fondo general de la aplicación
            Color(red: 245/255, green: 247/255, blue: 250/255).ignoresSafeArea()
            
            if viewModel.isLoading && viewModel.services.isEmpty {
                VStack(spacing: 12) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 74/255, green: 144/255, blue: 226/255)))
                        .scaleEffect(1.3)
                    Text("Cargando tus servicios...")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(.gray)
                }
            } else if viewModel.services.isEmpty {
                // MARK: Estado Vacío o Fallo del Servidor (Contenedor Punteado)
                VStack(spacing: 16) {
                    Text("○")
                        .font(.system(size: 60, weight: .light))
                        .foregroundColor(Color(red: 177/255, green: 179/255, blue: 179/255))
                        .frame(width: 80, height: 80)
                        .background(Color(red: 18/255, green: 162/255, blue: 255/255).opacity(0.05))
                        .clipShape(Circle())
                    
                    Text("Sin servicios activos")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 63/255, green: 68/255, blue: 67/255))
                    
                    Text(viewModel.errorMessage != nil ? "Error al cargar servicios. Intenta nuevamente." : "Si acabas de contratar un plan, puede tardar unos minutos en aparecer aquí")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 48)
                .background(Color.white)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(red: 177/255, green: 179/255, blue: 179/255), style: StrokeStyle(lineWidth: 2, dash: [5]))
                )
                .padding(.horizontal, 24)
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 16) {
                        ForEach(viewModel.services) { service in
                            ServiceCardComponent(service: service)
                        }
                        
                        // MARK: Cuadro de Información Adicional Inferior
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Información importante")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 63/255, green: 68/255, blue: 67/255))
                            Text("El estado de sincronización muestra la conexión en tiempo real con tu antena. Si experimentas problemas de conexión, verifica el estado aquí antes de contactar soporte.")
                                .font(.system(size: 12, weight: .regular, design: .rounded))
                                .foregroundColor(.secondary)
                                .lineSpacing(3)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
                        .padding(.horizontal, 24)
                    }
                    .padding(.top, 16)
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

// MARK: - Componente Flexible de Tarjeta de Servicio
struct ServiceCardComponent: View {
    let service: ServiceNetworkModel
    private let primaryBlue = Color(red: 74/255, green: 144/255, blue: 226/255)
    
    var body: some View {
        VStack(spacing: 0) {
            // Header Superior Azul Fibertel/Conecta
            HStack(spacing: 14) {
                ZStack {
                    Image(systemName: "zap.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }
                .frame(width: 44, height: 44)
                .background(Color.white.opacity(0.18))
                .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(service.plan?.name ?? "Plan Conecta Fibra")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("\(service.plan?.downloadSpeed ?? 0) Mbps · Fibra Óptica")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.85))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(primaryBlue)
            
            // Contenedor de datos internos
            VStack(spacing: 16) {
                // Estado del Servicio (Badge Dinámico Nativo)
                HStack {
                    Text("Estado del servicio")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.gray)
                    Spacer()
                    
                    let badge = getSyncStatusBadge(status: service.syncStatus)
                    HStack(spacing: 4) {
                        Image(systemName: badge.icon)
                            .font(.system(size: 10, weight: .bold))
                        Text(badge.label.uppercased())
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(badge.bgColor)
                    .foregroundColor(badge.color)
                    .cornerRadius(50)
                }
                
                // Dirección de la Vivienda
                HStack(alignment: .top, spacing: 12) {
                    ZStack {
                        Image(systemName: "map.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Color(red: 18/255, green: 162/255, blue: 255/255))
                    }
                    .frame(width: 36, height: 36)
                    .background(Color(red: 18/255, green: 162/255, blue: 255/255).opacity(0.07))
                    .cornerRadius(8)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("DIRECCIÓN DE INSTALACIÓN")
                            .font(.system(size: 9, weight: .bold, design: .rounded))
                            .foregroundColor(.gray)
                        Text(service.addressText ?? "Dirección no disponible")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(Color(.darkGray))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer()
                }
                
                Divider()
                
                // Distribución Dual de Costos e Información Mensual
                HStack {
                    HStack(spacing: 10) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.green)
                        VStack(alignment: .leading, spacing: 1) {
                            Text("MENSUALIDAD")
                                .font(.system(size: 9, weight: .bold, design: .rounded))
                                .foregroundColor(.gray)
                            Text("S/ \(service.monthlyAmount, specifier: "%.2f")")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundColor(Color(.darkGray))
                        }
                    }
                    Spacer()
                    HStack(spacing: 10) {
                        Image(systemName: "calendar")
                            .font(.system(size: 20))
                            .foregroundColor(Color(red: 18/255, green: 162/255, blue: 255/255))
                        VStack(alignment: .leading, spacing: 1) {
                            Text("FACTURACIÓN")
                                .font(.system(size: 9, weight: .bold, design: .rounded))
                                .foregroundColor(.gray)
                            Text("Día \(service.billingDay)")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(Color(.darkGray))
                        }
                    }
                }
            }
            .padding(18)
            .background(Color.white)
        }
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
        .padding(.horizontal, 24)
    }
    
    private func getSyncStatusBadge(status: String) -> (label: String, color: Color, bgColor: Color, icon: String) {
        switch status {
        case "synced", "ok":
            return ("Sincronizado", .green, Color.green.opacity(0.08), "checkmark.circle.fill")
        case "pending":
            return ("Pendiente", .orange, Color.orange.opacity(0.08), "clock.fill")
        case "error":
            return ("Error", .red, Color.red.opacity(0.08), "exclamationmark.triangle.fill")
        default:
            return ("Desconocido", .gray, Color.gray.opacity(0.08), "questionmark.circle.fill")
        }
    }
}
