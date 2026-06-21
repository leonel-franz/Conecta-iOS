//
//  PerfilView.swift
//  MovilCliente
//
//  Created by Leonel on 15/06/26.
//

import SwiftUI

// MARK: - ESTRUCTURA IDENTIFICABLE DE ALERTAS (AÑADIDA AL INICIO PARA SOLUCIONAR EL SCOPE)
struct AlertItem: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}

struct PerfilView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    
    private let primaryBlue = Color(red: 74/255, green: 144/255, blue: 226/255)
    private let textDark = Color(red: 63/255, green: 68/255, blue: 67/255)
    private let bgMain = Color(red: 245/255, green: 247/255, blue: 250/255)
    
    var body: some View {
        ZStack {
            bgMain.ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 0) {
                    
                    // Header Superior
                    VStack(spacing: 12) {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 64, height: 64)
                            .foregroundColor(.white)
                            .padding(.top, 20)
                        
                        Text("Mi Perfil")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("Información personal y servicios")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(.white.opacity(0.85))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 24)
                    .background(primaryBlue)
                    .padding(.bottom, 20)
                    
                    if viewModel.isLoading {
                        VStack(spacing: 12) {
                            ProgressView()
                                .scaleEffect(1.3)
                            Text("Cargando perfil...")
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 60)
                    } else if viewModel.profile == nil {
                        VStack(spacing: 16) {
                            Text("No se pudo cargar el perfil")
                                .font(.headline).foregroundColor(.red)
                            Button(action: { Task { await viewModel.refetchAll() } }) {
                                Text("Reintentar")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 10)
                                    .background(primaryBlue)
                                    .cornerRadius(12)
                            }
                        }
                        .padding(.top, 60)
                    } else {
                        let profileData = viewModel.profile!
                        
                        VStack(spacing: 20) {
                            
                            // Tarjeta de Identidad Básica
                            VStack(spacing: 12) {
                                HStack(spacing: 16) {
                                    ZStack {
                                        Image(systemName: "person.fill")
                                            .font(.title2).foregroundColor(.white)
                                    }
                                    .frame(width: 60, height: 60)
                                    .background(primaryBlue)
                                    .clipShape(Circle())
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(profileData.fullName)
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundColor(.primary)
                                        Text(profileData.email)
                                            .font(.subheadline).foregroundColor(.secondary)
                                    }
                                    Spacer()
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(20)
                            
                            // Formulario de edición / vista
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Datos personales y facturación")
                                            .font(.system(size: 16, weight: .bold))
                                        Text("Actualiza tu teléfono y datos para recibir comprobantes")
                                            .font(.system(size: 11)).foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    
                                    if !viewModel.isEditing {
                                        Button(action: { viewModel.handleEdit() }) {
                                            HStack(spacing: 4) {
                                                Image(systemName: "pencil")
                                                Text("Editar")
                                            }
                                            .font(.system(size: 12, weight: .bold))
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(primaryBlue.opacity(0.1))
                                            .foregroundColor(primaryBlue)
                                            .cornerRadius(10)
                                        }
                                    }
                                }
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Teléfono").font(.caption).foregroundColor(textDark).font(.system(size: 12, weight: .bold))
                                    if viewModel.isEditing {
                                        HStack {
                                            Image(systemName: "phone").foregroundColor(.gray)
                                            TextField("999 888 777", text: $viewModel.phone)
                                                .keyboardType(.phonePad)
                                        }
                                        .padding().background(Color(.systemGray6)).cornerRadius(12)
                                    } else {
                                        Text(profileData.phone ?? "No especificado")
                                            .font(.body).padding().frame(maxWidth: .infinity, alignment: .leading)
                                            .background(Color(.systemGray6)).cornerRadius(12)
                                    }
                                }
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Tipo de documento").font(.caption).foregroundColor(textDark).font(.system(size: 12, weight: .bold))
                                    if viewModel.isEditing {
                                        HStack(spacing: 12) {
                                            ForEach(["DNI", "RUC"], id: \.self) { option in
                                                Button(action: { viewModel.handleDocumentTypeSelect(option) }) {
                                                    HStack {
                                                        Image(systemName: viewModel.documentType == option ? "checkmark.circle.fill" : "circle")
                                                        Text(option)
                                                    }
                                                    .font(.system(size: 14, weight: .bold))
                                                    .padding(.horizontal, 16)
                                                    .padding(.vertical, 10)
                                                    .background(viewModel.documentType == option ? primaryBlue.opacity(0.1) : Color(.systemGray6))
                                                    .foregroundColor(viewModel.documentType == option ? primaryBlue : .gray)
                                                    .cornerRadius(20)
                                                }
                                            }
                                        }
                                    } else {
                                        Text(profileData.documentType ?? "No especificado")
                                            .font(.body).padding().frame(maxWidth: .infinity, alignment: .leading)
                                            .background(Color(.systemGray6)).cornerRadius(12)
                                    }
                                }
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Número de documento").font(.caption).foregroundColor(textDark).font(.system(size: 12, weight: .bold))
                                    if viewModel.isEditing {
                                        TextField("Ingresa dígitos", text: $viewModel.documentNumber)
                                            .keyboardType(.numberPad)
                                            .padding().background(Color(.systemGray6)).cornerRadius(12)
                                            .onChange(of: viewModel.documentNumber) { newValue in
                                                viewModel.handleDocumentNumberChange(newValue)
                                            }
                                    } else {
                                        Text(profileData.documentNumber ?? "No especificado")
                                            .font(.body).padding().frame(maxWidth: .infinity, alignment: .leading)
                                            .background(Color(.systemGray6)).cornerRadius(12)
                                    }
                                }
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Tipo de comprobante para pagos").font(.caption).foregroundColor(textDark).font(.system(size: 12, weight: .bold))
                                    if viewModel.isEditing {
                                        HStack(spacing: 12) {
                                            ForEach(["Boleta", "Factura"], id: \.self) { option in
                                                Button(action: { viewModel.billingType = option }) {
                                                    HStack {
                                                        Image(systemName: viewModel.billingType == option ? "checkmark.circle.fill" : "circle")
                                                        Text(option)
                                                    }
                                                    .font(.system(size: 14, weight: .bold))
                                                    .padding(.horizontal, 16)
                                                    .padding(.vertical, 10)
                                                    .background(viewModel.billingType == option ? primaryBlue.opacity(0.1) : Color(.systemGray6))
                                                    .foregroundColor(viewModel.billingType == option ? primaryBlue : .gray)
                                                    .cornerRadius(20)
                                                }
                                            }
                                        }
                                    } else {
                                        Text(profileData.billingDocumentType ?? "No especificado")
                                            .font(.body).padding().frame(maxWidth: .infinity, alignment: .leading)
                                            .background(Color(.systemGray6)).cornerRadius(12)
                                    }
                                }
                                
                                if viewModel.isEditing {
                                    HStack(spacing: 12) {
                                        Button(action: { Task { await viewModel.handleSave() } }) {
                                            HStack {
                                                if viewModel.isMutationPending { ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white)) }
                                                Text(viewModel.isMutationPending ? "Guardando..." : "Guardar cambios")
                                            }
                                            .font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                                            .frame(maxWidth: .infinity).padding().background(primaryBlue).cornerRadius(16)
                                        }
                                        .disabled(viewModel.isMutationPending)
                                        
                                        Button(action: { viewModel.handleCancel() }) {
                                            Text("Cancelar")
                                                .font(.system(size: 14, weight: .bold)).foregroundColor(primaryBlue)
                                                .frame(maxWidth: .infinity).padding().background(Color.white)
                                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(primaryBlue, lineWidth: 1.5))
                                        }
                                    }
                                    .padding(.top, 8)
                                }
                            }
                            .padding(20)
                            .background(Color.white)
                            .cornerRadius(24)
                            
                            // Lista de Servicios Colapsable
                            VStack(spacing: 12) {
                                Button(action: { withAnimation { viewModel.showServices.toggle() } }) {
                                    HStack {
                                        Image(systemName: "wifi").foregroundColor(primaryBlue)
                                        Text("Mis servicios contratados")
                                            .font(.system(size: 15, weight: .bold)).foregroundColor(.primary)
                                        Spacer()
                                        Image(systemName: viewModel.showServices ? "chevron.up" : "chevron.down")
                                            .foregroundColor(.gray)
                                    }
                                }
                                
                                if viewModel.showServices {
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text("Resumen de los planes de internet que tienes contratados")
                                            .font(.caption).foregroundColor(.secondary)
                                        
                                        if viewModel.servicesLoading {
                                            ProgressView().frame(maxWidth: .infinity).padding()
                                        } else if viewModel.services.isEmpty {
                                            Text("Aún no tienes servicios contratados.")
                                                .font(.subheadline).foregroundColor(.gray).padding(.vertical, 8)
                                        } else {
                                            ForEach(viewModel.services) { service in
                                                HStack {
                                                    VStack(alignment: .leading, spacing: 2) {
                                                        Text(service.plan?.name ?? "Plan Fibra")
                                                            .font(.system(size: 14, weight: .bold))
                                                        Text(service.addressText ?? "—")
                                                            .font(.caption).foregroundColor(.gray)
                                                    }
                                                    Spacer()
                                                    Text(viewModel.getStatusLabel(status: service.syncStatus))
                                                        .font(.system(size: 11, weight: .bold))
                                                        .padding(.horizontal, 8).padding(.vertical, 4)
                                                        .background(primaryBlue.opacity(0.1)).foregroundColor(primaryBlue).cornerRadius(6)
                                                }
                                                .padding(10).background(Color(.systemGray6)).cornerRadius(12)
                                            }
                                        }
                                    }
                                    .padding(.top, 4)
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(24)
                            
                            // Botón de Salida
                            Button(action: {
                                viewModel.alertMessage = (title: "Cerrar sesión", message: "¿Seguro que deseas salir?")
                            }) {
                                HStack {
                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                    Text("Cerrar sesión")
                                }
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity).padding().background(Color(red: 254/255, green: 242/255, blue: 242/255))
                                .cornerRadius(24)
                                .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color(red: 254/255, green: 202/255, blue: 202/255), lineWidth: 1.5))
                            }
                            .padding(.top, 8)
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
        }
        .task {
            await viewModel.loadProfileData()
        }
        .alert(item: Binding<AlertItem?>(
            get: { viewModel.alertMessage != nil ? AlertItem(title: viewModel.alertMessage!.title, message: viewModel.alertMessage!.message) : nil },
            set: { _ in viewModel.alertMessage = nil }
        )) { alert in
            if alert.title == "Cerrar sesión" {
                return Alert(title: Text(alert.title), message: Text(alert.message), primaryButton: .destructive(Text("Salir"), action: {
                    authViewModel.logout()
                }), secondaryButton: .cancel(Text("Cancelar")))
            } else {
                return Alert(title: Text(alert.title), message: Text(alert.message), dismissButton: .default(Text("Aceptar")))
            }
        }
    }
}

// MARK: - PREVIEW CORREGIDO PARA PERFILVIEW
struct PerfilView_Previews: PreviewProvider {
    static var previews: some View {
        PerfilView()
            .environmentObject(AuthViewModel())
            .previewDisplayName("Perfil Vista Real")
    }
}
