//
//  LoginView.swift
//  MovilCliente (iOS)
//
//  Created by Leonel on 12/06/26.
//

import SwiftUI

struct LoginView: View {
    // 1. Inyección del estado global de sesión mediante el ViewModel
    @StateObject private var authViewModel = AuthViewModel()
    
    // Estados locales para capturar los valores de los inputs
    @State private var email = ""
    @State private var password = ""
    
    // Manejo de foco e interfaz de errores (Equivalente a Zod + FocusedField)
    @State private var isEmailFocused = false
    @State private var isPasswordFocused = false
    @State private var emailError: String? = nil
    @State private var passwordError: String? = nil
    
    // Paleta cromática idéntica a la rúbrica de React Native
    private let backgroundColor = Color(red: 245/255, green: 247/255, blue: 250/255) // #F5F7FA
    private let primaryBlue = Color(red: 74/255, green: 144/255, blue: 226/255)   // #4A90E2
    private let primaryTeal = Color(red: 0/255, green: 205/255, blue: 184/255)   // #00CDB8
    private let textDark = Color(red: 63/255, green: 68/255, blue: 67/255)       // #3F4443
    
    var body: some View {
        // En iOS 15/Xcode 13, NavigationView gestiona la jerarquía de pantallas de manera óptima
        NavigationView {
            ZStack {
                // Color de fondo de la aplicación
                backgroundColor
                    .ignoresSafeArea()
                
                // ScrollView + KeyboardAvoiding nativo automático en SwiftUI
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        // MARK: - Sección del Logo
                        VStack {
                            // En tu proyecto final debes añadir 'logof' a tus Assets.xcassets
                            Image("logof")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 160, height: 160)
                                .padding(.top, 40)
                        }
                        
                        // MARK: - Tarjeta Contenedora del Formulario
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Bienvenido")
                                .font(.system(size: 26, weight: .bold, design: .rounded))
                                .foregroundColor(textDark)
                                .padding(.bottom, 4)
                            
                            Text("Ingresa tus datos para acceder")
                                .font(.system(size: 15, weight: .regular, design: .rounded))
                                .foregroundColor(.gray)
                                .padding(.bottom, 32)
                            
                            // MARK: Input de Correo Electrónico
                            Text("Correo Electrónico")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(textDark)
                                .padding(.bottom, 8)
                            
                            HStack {
                                Image(systemName: "envelope")
                                    .foregroundColor(isEmailFocused ? primaryBlue : .gray)
                                    .frame(width: 24)
                                
                                TextField("ejemplo@correo.com", text: $email, onEditingChanged: { focused in
                                    isEmailFocused = focused
                                    if !focused { validateEmail() }
                                })
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                            }
                            .padding()
                            .background(isEmailFocused ? primaryBlue.opacity(0.08) : Color(.systemGray6))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(emailError != nil ? Color.red : (isEmailFocused ? primaryBlue : Color.clear), lineWidth: 1.5)
                            )
                            
                            if let error = emailError {
                                Text(error)
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(.red)
                                    .padding(.top, 4)
                                    .padding(.leading, 4)
                            }
                            
                            // MARK: Input de Contraseña
                            Text("Contraseña")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(textDark)
                                .padding(.top, 20)
                                .padding(.bottom, 8)
                            
                            HStack {
                                Image(systemName: "lock")
                                    .foregroundColor(isPasswordFocused ? primaryBlue : .gray)
                                    .frame(width: 24)
                                
                                SecureField("••••••••••", text: $password)
                                    // Simulación de eventos onFocus/onBlur mediante gestos e interacción nativa en iOS 15
                                    .onTapGesture { isPasswordFocused = true }
                                    .font(.system(size: 16, weight: .regular, design: .rounded))
                            }
                            .padding()
                            .background(isPasswordFocused ? primaryBlue.opacity(0.08) : Color(.systemGray6))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(passwordError != nil ? Color.red : (isPasswordFocused ? primaryBlue : Color.clear), lineWidth: 1.5)
                            )
                            
                            if let error = passwordError {
                                Text(error)
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(.red)
                                    .padding(.top, 4)
                                    .padding(.leading, 4)
                            }
                            
                            // MARK: Botón de Inicio de Sesión
                            Button(action: {
                                // Quitar foco de teclados
                                isEmailFocused = false
                                isPasswordFocused = false
                                executeLoginAction()
                            }) {
                                HStack {
                                    if authViewModel.isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    } else {
                                        Text("Iniciar Sesión")
                                            .font(.system(size: 16, weight: .bold, design: .rounded))
                                            .foregroundColor(.white)
                                        Image(systemName: "arrow.right")
                                            .foregroundColor(.white)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: authViewModel.isLoading ? [Color.gray] : [primaryBlue, primaryTeal]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(12)
                                .shadow(color: primaryBlue.opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                            .disabled(authViewModel.isLoading)
                            .padding(.top, 32)
                            
                            // MARK: Botón de WhatsApp para no clientes
                            Link(destination: URL(string: "https://wa.me/51923360859?text=Hola%20Conecta,%20deseo%20m%C3%A1s%20informaci%C3%B3n%20para%20contratar%20un%20nuevo%20servicio%20de%20internet.")!) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("¿Aún no eres cliente?")
                                            .font(.system(size: 12, weight: .medium, design: .rounded))
                                            .foregroundColor(.white.opacity(0.9))
                                        Text("Solicita tu instalación por WhatsApp")
                                            .font(.system(size: 13, weight: .bold, design: .rounded))
                                            .foregroundColor(.white)
                                            .multilineTextAlignment(.leading)
                                    }
                                    Spacer()
                                    Image(systemName: "text.bubble.fill")
                                        .font(.system(size: 22))
                                        .foregroundColor(.white)
                                        .padding(10)
                                        .background(Color.white.opacity(0.2))
                                        .clipShape(Circle())
                                }
                                .padding()
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color(red: 37/255, green: 211/255, blue: 102/255), Color(red: 18/255, green: 140/255, blue: 126/255)]),
                                        startPoint: .leading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .cornerRadius(16)
                                .shadow(color: Color(red: 37/255, green: 211/255, blue: 102/255).opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                            .padding(.top, 24)
                            
                        }
                        .padding(24)
                        .background(Color.white)
                        .cornerRadius(24)
                        .shadow(color: Color.black.opacity(0.05), radius: 12, x: 0, y: 6)
                        .padding(.horizontal, 20)
                    }
                }
            }
            .navigationBarHidden(true)
            // Escucha cambios en el ViewModel para alertar errores del servidor/Supabase
            .alert(item: Binding<AlertError?>(
                get: { authViewModel.errorMessage != nil ? AlertError(message: authViewModel.errorMessage!) : nil },
                set: { _ in authViewModel.errorMessage = nil }
            )) { error in
                Alert(title: Text("Error de acceso"), message: Text(error.message), dismissButton: .default(Text("Aceptar")))
            }
        }
    }
    
    // MARK: - Funciones de Validación Locales (Reemplazo de Zod de React Native)
    private func validateEmail() {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        if email.isEmpty {
            emailError = "El correo electrónico es requerido"
        } else if !emailPredicate.evaluate(with: email) {
            emailError = "Ingresa un email válido"
        } else {
            emailError = nil
        }
    }
    
    private func validatePassword() {
        if password.isEmpty {
            passwordError = "La contraseña es requerida"
        } else if password.count < 6 {
            passwordError = "La contraseña debe tener al menos 6 caracteres"
        } else {
            passwordError = nil
        }
    }
    
    private func executeLoginAction() {
        validateEmail()
        validatePassword()
        
        // Si no existen errores locales, procedemos a disparar el hilo asíncrono hacia el backend
        if emailError == nil && passwordError == nil {
            Task {
                await authViewModel.login(email: email.trimmingCharacters(in: .whitespacesAndNewlines), password: password)
            }
        }
    }
}

// Estructura identificable para lanzar alertas nativas basadas en Strings opcionales
struct AlertError: Identifiable {
    let id = UUID()
    let message: String
}

// Vista previa para renderizar en Xcode
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

