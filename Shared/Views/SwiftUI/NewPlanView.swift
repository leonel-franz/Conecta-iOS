//
//  NewPlanView.swift
//  MovilCliente
//
//  Created by Antony on 16/06/26.
//

import SwiftUI
import MapKit

struct NewPlanView: View {
    @Environment(\.dismiss) var dismiss
    @State private var addressText: String = ""
    @State private var isSubmitting = false
    @State private var selectedPlan = "Plan Conecta Fibra 200 Mbps"
    
    // Región por defecto de geolocalización de Lima (Mismo fallback que tu mapa de Expo)
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -12.046374, longitude: -77.042793),
        span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
    )
    
    private let primaryColor = Color(red: 0.17, green: 0.62, blue: 0.70) // #2B9EB3
    private let gradientBlue = Color(red: 74/255, green: 144/255, blue: 226/255)
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header
            LinearGradient(gradient: Gradient(colors: [gradientBlue, primaryColor]), startPoint: .leading, endPoint: .trailing)
                .frame(height: 90)
                .overlay(
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .bold)).foregroundColor(.white)
                        }
                        Text("Solicitar Nuevo Plan")
                            .font(.system(size: 20, weight: .bold, design: .rounded)).foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 30),
                    alignment: .top
                )
                .ignoresSafeArea(.all, edges: .top)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // ESCALÓN 1: Selector del Plan Ideal
                    VStack(alignment: .leading, spacing: 10) {
                        Text("1. Escoge el plan ideal")
                            .font(.system(size: 16, weight: .bold)).foregroundColor(.primary)
                        
                        Menu {
                            Button("Plan Conecta Fibra 100 Mbps - S/ 79.90", action: { selectedPlan = "Plan Conecta Fibra 100 Mbps" })
                            Button("Plan Conecta Fibra 200 Mbps - S/ 99.90", action: { selectedPlan = "Plan Conecta Fibra 200 Mbps" })
                            Button("Plan Conecta Fibra 500 Mbps - S/ 149.90", action: { selectedPlan = "Plan Conecta Fibra 500 Mbps" })
                        } label: {
                            HStack {
                                Image(systemName: "wifi").foregroundColor(primaryColor)
                                Text(selectedPlan)
                                    .font(.system(size: 15, weight: .semibold)).foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.down").foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color(.secondarySystemGroupedBackground))
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.04), radius: 6)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // ESCALÓN 2: Dirección y Mapa Interactivo MapKit Nativo
                    VStack(alignment: .leading, spacing: 12) {
                        Text("2. Dirección de Instalación")
                            .font(.system(size: 16, weight: .bold)).foregroundColor(.primary)
                        
                        TextField("Ej. Av. Las Flores 452, San Isidro", text: $addressText)
                            .padding()
                            .background(Color(.secondarySystemGroupedBackground))
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.03), radius: 4)
                        
                        Text("Ubicación exacta (Arrastra el mapa)")
                            .font(.caption2).foregroundColor(.secondary)
                        
                        // Renderizado de mapa vectorial nativo por GPU de Apple
                        ZStack {
                            Map(coordinateRegion: $region)
                                .frame(height: 200)
                                .cornerRadius(20)
                            
                            // Pin flotante estático en el centro exacto de la retícula
                            VStack(spacing: 0) {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.title).foregroundColor(.red)
                                Circle().fill(Color.black.opacity(0.2)).frame(width: 8, height: 3)
                            }
                            .offset(y: -14)
                        }
                    }
                    .padding(.horizontal)
                    
                    // BOTÓN DE ENVÍO DE ACCIÓN COMERCIAL
                    Button(action: { procesarEnvioServicio() }) {
                        ZStack {
                            if isSubmitting {
                                ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("SOLICITAR SERVICIO")
                                    .font(.system(size: 15, weight: .bold)).tracking(1)
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(addressText.isEmpty ? Color.gray : primaryColor)
                        .cornerRadius(32)
                    }
                    .disabled(addressText.isEmpty || isSubmitting)
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    private func procesarEnvioServicio() {
        self.isSubmitting = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isSubmitting = false
            let alert = UIAlertController(title: "Éxito", message: "Tu solicitud de nuevo servicio ha sido transmitida al departamento de operaciones de Conecta.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Excelente", style: .default, handler: { _ in
                dismiss()
            }))
            
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let root = scene.windows.first?.rootViewController {
                root.present(alert, animated: true)
            }
        }
    }
}
