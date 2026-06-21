//
//  PagosViewModel.swift
//  MovilCliente
//
//  Created by Antony on 16/06/26.
//

import Foundation
import Combine

enum PaymentStep {
    case config, loading, paying, success
}

enum PaymentMethodType: String, CaseIterable {
    case mercadoPagoQR = "QR Mercado Pago"
    case openpayLink = "Link de Pago Openpay"
    case openpayCard = "Openpay Tarjeta"
    case openpayQR = "Yape y Plin (QR)"
    case openpayStore = "Agentes y Bodegas"
    case openpayYapeDirect = "Yape con código"
}

@MainActor
class PagosViewModel: ObservableObject {
    @Published var invoices: [InvoiceNetworkModel] = []
    @Published var totalPending: Double = 0.0
    @Published var isLoading: Bool = false
    @Published var activeTab: Int = 0 // 0: Pendientes, 1: Historial
    
    // Estados del Modal de Pagos
    @Published var paymentModalOpen: Bool = false
    @Published var selectedInvoice: InvoiceNetworkModel? = nil
    @Published var chosenDocumentType: String = "BOLETA"
    @Published var paymentMethod: PaymentMethodType = .mercadoPagoQR
    @Published var paymentStep: PaymentStep = .config
    @Published var qrCodeURL: String = ""
    @Published var referenceCIP: String = ""
    
    // Formulario Yape Directo
    @Published var yapePhone: String = ""
    @Published var yapeOTP: String = ""
    @Published var yapeError: String? = nil
    
    func loadDashboardData() async {
        self.isLoading = true
        
        // Simulación de deudas reales de Conecta (Mismo comportamiento que tu useQuery)
        try? await Task.sleep(nanoseconds: 800_000_000)
        
        self.invoices = [
            InvoiceNetworkModel(id: "INV-2026-001", status: "pending", dueDate: "2026-06-20T00:00:00Z", total: 89.90),
            InvoiceNetworkModel(id: "INV-2026-002", status: "pending", dueDate: "2026-05-15T00:00:00Z", total: 119.90),
            InvoiceNetworkModel(id: "INV-2026-003", status: "paid", dueDate: "2026-04-15T00:00:00Z", total: 89.90)
        ]
        
        recalcularDeuda()
        self.isLoading = false
    }
    
    private func recalcularDeuda() {
        self.totalPending = invoices
            .filter { $0.status == "pending" }
            .reduce(0.0) { $0 + ($1.total ?? 0.0) }
    }
    
    func iniciarFlujoPago(con invoice: InvoiceNetworkModel) {
        self.selectedInvoice = invoice
        self.paymentStep = .config
        self.paymentModalOpen = true
        self.yapeError = nil
        self.yapePhone = ""
        self.yapeOTP = ""
    }
    
    func procesarConfirmacionPago() async {
        guard let invoice = selectedInvoice else { return }
        self.paymentStep = .loading
        
        // Simulación de latencia de red de las API de pasarela
        try? await Task.sleep(nanoseconds: 1_200_000_000)
        
        // MARK: - BYPASS INTERCEPTOR DE PASARELAS (PARIDAD OFFLINE)
        switch paymentMethod {
        case .mercadoPagoQR:
            self.qrCodeURL = "https://api.qrserver.com/v1/create-qr-code/?data=MercadoPagoBypass2026&size=200x200"
            self.paymentStep = .paying
            dispararSimuladorPolling()
            
        case .openpayQR:
            self.qrCodeURL = "https://api.qrserver.com/v1/create-qr-code/?data=OpenpayYapeQRBypass&size=200x200"
            self.paymentStep = .paying
            dispararSimuladorPolling()
            
        case .openpayStore:
            self.referenceCIP = "CIP-7412589"
            self.paymentStep = .paying
            dispararSimuladorPolling()
            
        case .openpayYapeDirect:
            self.paymentStep = .paying // Abre el formulario nativo del OTP de 6 dígitos
            
        case .openpayCard, .openpayLink:
            // Simulación directa de Webview exitoso
            self.paymentStep = .success
            completarReciboLocalmente(id: invoice.id)
        }
    }
    
    func ejecutarYapeDirecto() async {
        guard let invoice = selectedInvoice else { return }
        if yapePhone.count < 9 {
            self.yapeError = "Ingresa un celular de 9 dígitos"
            return
        }
        if yapeOTP.count != 6 {
            self.yapeError = "El código debe tener 6 dígitos"
            return
        }
        
        self.paymentStep = .loading
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        self.paymentStep = .success
        completarReciboLocalmente(id: invoice.id)
    }
    
    private func dispararSimuladorPolling() {
        // Simula el webhook del banco que aprueba el pago automáticamente a los 6 segundos
        Task {
            try? await Task.sleep(nanoseconds: 6_000_000_000)
            if self.paymentStep == .paying, let inv = selectedInvoice {
                self.paymentStep = .success
                completarReciboLocalmente(id: inv.id)
            }
        }
    }
    
    private func completarReciboLocalmente(id: String) {
        if let idx = invoices.firstIndex(where: { $0.id == id }) {
            // Actualizamos el estado localmente para reflejar el éxito en tiempo real en la UI
            let old = invoices[idx]
            invoices[idx] = InvoiceNetworkModel(id: old.id, status: "paid", dueDate: old.dueDate, total: old.total)
            recalcularDeuda()
        }
    }
}
