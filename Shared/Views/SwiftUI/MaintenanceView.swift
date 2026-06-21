//
//  MaintenanceView.swift
//  MovilCliente
//
//  Created by Antony on 16/06/26.
//

import SwiftUI

struct MaintenanceView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedIssue: String? = nil
    @State private var description: String = ""
    @State private var isSubmitting = false
    
    private let issues = [
        "Sin acceso a internet", "Internet lento", "Intermitencia / Cortes",
        "Cable de fibra roto", "Cambio de clave WiFi", "Traslado de domicilio", "Otro"
    ]
    
    private let primaryColor = Color(red: 0.17, green: 0.62, blue: 0.70) // #2B9EB3
    private let lightBlue = Color(red: 184/255, green: 234/255, blue: 245/255)
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header con Gradiente original de Conecta
            LinearGradient(gradient: Gradient(colors: [lightBlue, Color(.systemBackground)]), startPoint: .top, endPoint: .bottom)
                .frame(height: 80)
                .overlay(
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.title3).foregroundColor(.primary)
                        }
                        Text("Reportar Problema")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(Color(.darkLabel))
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20),
                    alignment: .top
                )
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // SECCIÓN 1: Servicio Afectado
                    VStack(alignment: .leading, spacing: 10) {
                        Text("1. Servicio Afectado")
                            .font(.system(size: 14, weight: .bold)).foregroundColor(.secondary)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("Plan Conecta Hogar 100 Mbps").font(.headline)
                                Spacer()
                                Image(systemName: "checkmark.circle.fill").foregroundColor(primaryColor)
                            }
                            Text("Av. Principal 123, San Isidro").font(.caption).foregroundColor(.gray)
                            Text("IP: 192.168.100.45").font(.caption2).foregroundColor(.gray)
                        }
                        .padding()
                        .background(primaryColor.opacity(0.05))
                        .cornerRadius(16)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(primaryColor, lineWidth: 2))
                    }
                    .padding(.horizontal)
                    
                    // SECCIÓN 2: Tipo de Problema (Pills dinámicas con Flex Wrap de tu array ISSUES)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("2. Tipo de Problema")
                            .font(.system(size: 14, weight: .bold)).foregroundColor(.secondary)
                        
                        // Diseño de flujo adaptativo nativo para las averías
                        ForEach(issues, id: \.self) { issue in
                            Button(action: { selectedIssue = issue }) {
                                HStack {
                                    Text(issue)
                                        .font(.system(size: 14, weight: .medium))
                                    Spacer()
                                    Circle()
                                        .fill(selectedIssue == issue ? primaryColor : Color.clear)
                                        .frame(width: 12, height: 12)
                                        .background(Circle().stroke(Color.gray, lineWidth: 1))
                                }
                                .padding()
                                .background(selectedIssue == issue ? primaryColor.opacity(0.1) : Color(.secondarySystemGroupedBackground))
                                .foregroundColor(selectedIssue == issue ? primaryColor : .primary)
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // SECCIÓN 3: Detalle Adicional
                    VStack(alignment: .leading, spacing: 10) {
                        Text("3. Detalle Adicional (Opcional)")
                            .font(.system(size: 14, weight: .bold)).foregroundColor(.secondary)
                        
                        TextEditor(text: $description)
                            .frame(height: 100)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // BOTÓN DE ACCIÓN FINAL (Misma mutación offline/online de tu React Native)
                    Button(action: { ejecutarEnvioTicket() }) {
                        ZStack {
                            if isSubmitting {
                                ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Generar Ticket")
                                    .font(.system(size: 16, weight: .bold))
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedIssue == nil ? Color.gray : primaryColor)
                        .cornerRadius(16)
                        .shadow(color: primaryColor.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .disabled(selectedIssue == nil || isSubmitting)
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    private func ejecutarEnvioTicket() {
        self.isSubmitting = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            self.isSubmitting = false
            // Calca de tu Alert.alert de React Native
            let alert = UIAlertController(title: "Ticket Generado (Offline)", message: "Tu solicitud ha sido registrada bajo simulación técnica UISP.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Entendido", style: .default, handler: { _ in
                dismiss()
            }))
            
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let root = scene.windows.first?.rootViewController {
                root.present(alert, animated: true)
            }
        }
    }
}
