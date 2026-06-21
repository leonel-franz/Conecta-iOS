//
//  PagosView.swift
//  MovilCliente
//
//  Created by Antony on 16/06/26.
//

import SwiftUI

struct PagosView: View {
    @StateObject private var viewModel = PagosViewModel()
    
    // MARK: - Variables de Control para el Visor de Documentos
    @State private var mostrarVisorPDF = false
    @State private var urlPdfSeleccionado = ""
    @State private var tituloPdfSeleccionado = ""
    
    private let bgMain = Color(red: 245/255, green: 247/255, blue: 250/255)
    private let primaryColor = Color(red: 0.17, green: 0.62, blue: 0.70) // #2B9EB3
    private let primaryBlue = Color(red: 74/255, green: 144/255, blue: 226/255)
    
    var body: some View {
        ZStack {
            bgMain.ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 16) {
                    
                    // MARK: - Header Premium
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(gradient: Gradient(colors: [primaryBlue, primaryColor]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 64, height: 64)
                            Image(systemName: "creditcard.fill")
                                .font(.title2).foregroundColor(.white)
                        }
                        Text("Mi Billetera")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(primaryColor)
                        Text("Gestiona tus pagos y facturas de internet")
                            .font(.caption).foregroundColor(.gray)
                    }
                    .padding(.top, 20)
                    
                    // MARK: - Tarjeta Deuda Total Hero
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "wallet.pass.fill")
                                .foregroundColor(.white).font(.headline)
                            Text("DEUDA PENDIENTE")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white.opacity(0.9))
                        }
                        
                        Text("S/ \(viewModel.totalPending, specifier: "%.2f")")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Divider().background(Color.white.opacity(0.3))
                        
                        HStack {
                            Text("Facturas emitidas: \(viewModel.invoices.count)")
                                .font(.caption).foregroundColor(.white.opacity(0.9))
                            Spacer()
                            Text("Junio 2026")
                                .font(.caption).bold().foregroundColor(.white)
                        }
                    }
                    .padding(24)
                    .background(
                        LinearGradient(gradient: Gradient(colors: [primaryBlue, primaryColor]), startPoint: .leading, endPoint: .trailing)
                    )
                    .cornerRadius(28)
                    .padding(.horizontal)
                    
                    // MARK: - Selector Tabs (Pendientes vs Historial)
                    HStack(spacing: 0) {
                        Button(action: { viewModel.activeTab = 0 }) {
                            Text("Pendientes")
                                .font(.system(size: 14, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(viewModel.activeTab == 0 ? primaryBlue : Color.clear)
                                .foregroundColor(viewModel.activeTab == 0 ? .white : .gray)
                                .cornerRadius(20)
                        }
                        
                        Button(action: { viewModel.activeTab = 1 }) {
                            Text("Historial")
                                .font(.system(size: 14, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(viewModel.activeTab == 1 ? primaryBlue : Color.clear)
                                .foregroundColor(viewModel.activeTab == 1 ? .white : .gray)
                                .cornerRadius(20)
                        }
                    }
                    .padding(4)
                    .background(Color(.systemGray6))
                    .cornerRadius(24)
                    .padding(.horizontal)
                    
                    // MARK: - Lista de Facturas Filtrada
                    let filteredInvoices = viewModel.invoices.filter {
                        viewModel.activeTab == 0 ? ($0.status == "pending") : ($0.status == "paid")
                    }
                    
                    if filteredInvoices.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: viewModel.activeTab == 0 ? "checkmark.circle.fill" : "clock.fill")
                                .font(.system(size: 40)).foregroundColor(.gray.opacity(0.5))
                            Text(viewModel.activeTab == 0 ? "¡Todo al día!" : "Sin historial")
                                .font(.headline).foregroundColor(.secondary)
                        }
                        .padding(.top, 40)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(filteredInvoices, id: \.id) { inv in
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Image(systemName: "doc.plaintext.fill")
                                            .foregroundColor(primaryBlue).font(.title3)
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Recibo FiberConecta")
                                                .font(.system(size: 14, weight: .bold))
                                            Text("#\(inv.id)")
                                                .font(.caption2).foregroundColor(.gray)
                                        }
                                        Spacer()
                                        
                                        Text(inv.status == "pending" ? "Vencido" : "Pagado")
                                            .font(.system(size: 10, weight: .bold))
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(inv.status == "pending" ? Color.red.opacity(0.1) : Color.green.opacity(0.1))
                                            .foregroundColor(inv.status == "pending" ? .red : .green)
                                            .cornerRadius(6)
                                    }
                                    
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text("Vencimiento").font(.caption2).foregroundColor(.gray)
                                            Text("20 Jun 2026").font(.system(size: 13, weight: .semibold))
                                        }
                                        Spacer()
                                        VStack(alignment: .trailing) {
                                            Text("Monto").font(.caption2).foregroundColor(.gray)
                                            Text("S/ \(inv.total ?? 0.0, specifier: "%.2f")").font(.system(size: 16, weight: .black))
                                        }
                                    }
                                    .padding(12)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                                    
                                    if inv.status == "pending" {
                                        Button(action: { viewModel.iniciarFlujoPago(con: inv) }) {
                                            Text("Pagar ahora")
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundColor(.white)
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 12)
                                                .background(primaryBlue)
                                                .cornerRadius(14)
                                        }
                                    } else {
                                        // MARK: Enlace Reactivo al nuevo DocumentViewerView
                                        Button(action: {
                                            self.urlPdfSeleccionado = "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf"
                                            self.tituloPdfSeleccionado = "Recibo Conecta #\(inv.id)"
                                            self.mostrarVisorPDF = true
                                        }) {
                                            HStack(spacing: 8) {
                                                Text("Ver Comprobante Electrónico")
                                                    .font(.system(size: 13, weight: .bold))
                                                Image(systemName: "eye.fill")
                                            }
                                            .foregroundColor(primaryColor)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background(primaryColor.opacity(0.08))
                                            .cornerRadius(14)
                                        }
                                    }
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(20)
                                .padding(.horizontal)
                            }
                        }
                    }
                }
            }
        }
        .task {
            await viewModel.loadDashboardData()
        }
        // MARK: - MODAL 1: PASARELA Y FORMULARIO DE PAGOS (BOLETA / FACTURA / PICKERS)
                .sheet(isPresented: $viewModel.paymentModalOpen) {
                    NavigationView {
                        VStack {
                            if viewModel.paymentStep == .config {
                                Form {
                                    Section(header: Text("Tipo de Comprobante")) {
                                        Picker("Documento", text: $viewModel.chosenDocumentType) {
                                            Text("Boleta (DNI)").tag("BOLETA")
                                            Text("Factura (RUC)").tag("FACTURA")
                                        }
                                        .pickerStyle(.segmented)
                                    }
                                    
                                    Section(header: Text("Método de Pago")) {
                                        Picker("Pasarela", selection: $viewModel.paymentMethod) {
                                            ForEach(PaymentMethodType.allCases, id: \.self) { method in
                                                Text(method.rawValue).tag(method)
                                            }
                                        }
                                        .pickerStyle(.inline)
                                    }
                                }
                                
                                Button(action: { Task { await viewModel.procesarConfirmacionPago() } }) {
                                    Text("Continuar con el Pago")
                                        .font(.headline).foregroundColor(.white)
                                        .frame(maxWidth: .infinity).padding().background(primaryBlue).cornerRadius(16)
                                }
                                .padding()
                                
                            } else if viewModel.paymentStep == .loading {
                                VStack(spacing: 16) {
                                    ProgressView()
                                    Text("Estableciendo conexión segura con la pasarela...").font(.subheadline).foregroundColor(.gray)
                                }
                                
                            } else if viewModel.paymentStep == .paying {
                                VStack(spacing: 20) {
                                    Text("Completa tu transacción").font(.headline)
                                    
                                    if viewModel.paymentMethod == .mercadoPagoQR || viewModel.paymentMethod == .openpayQR {
                                        Text("Escanea este código QR desde tu app bancaria:").font(.caption).foregroundColor(.gray)
                                        Image(systemName: "qrcode")
                                            .font(.system(size: 140))
                                            .padding()
                                    } else if viewModel.paymentMethod == .openpayStore {
                                        Text("Presenta este código CIP en cualquier agente autorizado:").font(.caption).foregroundColor(.gray)
                                        Text(viewModel.referenceCIP)
                                            .font(.system(size: 24, weight: .black, design: .monospaced))
                                            .padding().background(Color(.systemGray6)).cornerRadius(12)
                                    } else if viewModel.paymentMethod == .openpayYapeDirect {
                                        TextField("Celular Yape", text: $viewModel.yapePhone).keyboardType(.phonePad).padding().background(Color(.systemGray6)).cornerRadius(12)
                                        SecureField("Código OTP (6 dígitos)", text: $viewModel.yapeOTP).keyboardType(.numberPad).padding().background(Color(.systemGray6)).cornerRadius(12)
                                        if let err = viewModel.yapeError { Text(err).font(.caption).foregroundColor(.red) }
                                        
                                        Button(action: { Task { await viewModel.ejecutarYapeDirecto() } }) {
                                            Text("Validar Yape").foregroundColor(.white).frame(maxWidth: .infinity).padding().background(Color.purple).cornerRadius(12)
                                        }
                                    }
                                    
                                    Text("Verificando confirmación del webhook...").font(.caption2).foregroundColor(.gray)
                                    ProgressView()
                                }
                                .padding()
                                
                            } else if viewModel.paymentStep == .success {
                                VStack(spacing: 16) {
                                    Image(systemName: "checkmark.circle.fill").font(.system(size: 60)).foregroundColor(.green)
                                    Text("¡Pago Procesado con Éxito!").font(.title3).bold()
                                    Text("Tu saldo se ha actualizado en el sistema UISP de Conecta.").font(.caption).foregroundColor(.gray).multilineTextAlignment(.center).padding(.horizontal)
                                    
                                    Button(action: { viewModel.paymentModalOpen = false }) {
                                        Text("Entendido").font(.headline).foregroundColor(.white).frame(maxWidth: .infinity).padding().background(primaryBlue).cornerRadius(12)
                                    }
                                }
                                .padding()
                            }
                        }
                        .navigationTitle("Pasarela Digital Conecta")
                        .navigationBarTitleDisplayMode(.inline)
                    }
                }
                // MARK: - MODAL 2: VISOR DE COMPROBANTES CON RE-DIRECCIÓN DE GOOGLE DOCS Y XML DUAL SUNAT
                .sheet(isPresented: $mostrarVisorPDF) {
                    DocumentViewerView(
                        url: urlPdfSeleccionado,
                        title: tituloPdfSeleccionado,
                        xmlUrl: "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf"
                    )
                }
            }
        }

        // MARK: - PREVIEW FIEL
        struct PagosView_Previews: PreviewProvider {
            static var previews: some View {
                PagosView()
            }
        }
