//
//  DocumentViewerView.swift
//  MovilCliente
//
//  Created by Antony on 16/06/26.
//

import SwiftUI
import WebKit

// MARK: - COMPONENTE WEBKIT ADAPTADO A GOOGLE DOCS VIEWER (PARIDAD ORIGINAL)
struct PDFWebKitRepresentable: UIViewRepresentable {
    let url: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.backgroundColor = .white
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard !url.isEmpty else { return }
        
        // Calca exacta de tu lógica useMemo: Forzar Google Docs Viewer para máxima compatibilidad
        let urlFormateada: String
        if url.lowercased().hasSuffix(".pdf") || url.contains("nubefact") || url.contains("/pdf/") || url.contains("pdf_url") {
            if let encodedUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                urlFormateada = "https://docs.google.com/gview?embedded=true&url=\(encodedUrl)"
            } else {
                urlFormateada = url
            }
        } else {
            urlFormateada = url
        }
        
        if let targetURL = URL(string: urlFormateada) {
            let request = URLRequest(url: targetURL)
            uiView.load(request)
        }
    }
}

// MARK: - INTERFAZ DE USUARIO (Paridad estricta con tu DocumentViewerScreen)
struct DocumentViewerView: View {
    let url: String
    let title: String?
    let xmlUrl: String?
    
    @Environment(\.dismiss) var dismiss
    
    // Paleta cromática original de tu código
    private let primaryBlue = Color(red: 18/255, green: 162/255, blue: 255/255) // #12A2FF
    private let bgGradientStart = Color(red: 91/255, green: 159/255, blue: 237/255) // #5B9FED
    private let bgGradientEnd = Color(red: 124/255, green: 181/255, blue: 245/255) // #7CB5F5
    private let bgBackground = Color(red: 245/255, green: 247/255, blue: 250/255) // #F5F7FA
    
    var body: some View {
        VStack(spacing: 0) {
            
            // MARK: - Header (Paridad con Lucide Icons)
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color(red: 63/255, green: 68/255, blue: 67/255))
                        .padding(8)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                }
                
                Spacer()
                
                Text(title ?? "Comprobante")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 63/255, green: 68/255, blue: 67/255))
                    .lineLimit(1)
                
                Spacer()
                
                Button(action: { openInBrowser(link: url) }) {
                    Image(systemName: "arrow.up.right.bundle.to.top")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(primaryBlue)
                        .padding(8)
                        .background(primaryBlue.opacity(0.1))
                        .clipShape(Circle())
                }
            }
            .padding()
            .background(Color.white)
            
            if url.isEmpty {
                // Alerta de Error si no hay URL
                VStack(spacing: 12) {
                    Text("Error: no hay documento para mostrar")
                        .font(.headline).foregroundColor(.red)
                    Button(action: { dismiss() }) {
                        Text("Volver")
                            .foregroundColor(.white).padding().background(primaryBlue).cornerRadius(12)
                    }
                }
                .frame(maxHeight: .infinity)
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {
                        
                        // MARK: - Contenedor WebView Vista Previa (Altura 280 exactos de tu código)
                        ZStack(alignment: .topLeading) {
                            PDFWebKitRepresentable(url: url)
                                .frame(height: 280)
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color(.systemGray5), lineWidth: 1)
                                )
                            
                            Text("Vista previa")
                                .font(.system(size: 11))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.black.opacity(0.5))
                                .cornerRadius(8)
                                .padding([.top, .left], 10)
                        }
                        .padding(.horizontal)
                        .padding(.top, 16)
                        
                        // MARK: - Botones de Descarga y Acción Comercial
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Descargar comprobante")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                            
                            // Botón PDF con Gradiente exacto
                            Button(action: { openInBrowser(link: url) }) {
                                HStack(spacing: 10) {
                                    Image(systemName: "arrow.down.doc.fill")
                                    Text("Descargar PDF")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    LinearGradient(gradient: Gradient(colors: [bgGradientStart, bgGradientEnd]), startPoint: .leading, endPoint: .trailing)
                                )
                                .cornerRadius(14)
                            }
                            .padding(.horizontal)
                            
                            // Botón XML condicional (Misma lógica if de React Native)
                            if let xml = xmlUrl, !xml.isEmpty {
                                Button(action: { openInBrowser(link: xml) }) {
                                    HStack(spacing: 10) {
                                        Image(systemName: "doc.plaintext.fill")
                                        Text("Descargar XML")
                                            .font(.system(size: 16, weight: .semibold))
                                    }
                                    .foregroundColor(Color(red: 63/255, green: 68/255, blue: 67/255))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color.white)
                                    .cornerRadius(14)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(Color(.systemGray4), lineWidth: 1)
                                    )
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // Mensaje de Advertencia SUNAT Legal
                        VStack(alignment: .leading) {
                            Text("El PDF y el XML tienen validez tributaria. Puedes abrirlos en el navegador o guardarlos en tu dispositivo.")
                                .font(.system(size: 12))
                                .foregroundColor(Color.blue.opacity(0.8))
                                .lineSpacing(5)
                        }
                        .padding()
                        .background(Color.blue.opacity(0.06))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.blue.opacity(0.12), lineWidth: 1)
                        )
                        .padding(.horizontal)
                    }
                }
                .background(bgBackground)
            }
        }
    }
    
    private func openInBrowser(link: String) {
        guard let targetURL = URL(string: link) else { return }
        UIApplication.shared.open(targetURL)
    }
}

// MARK: - PREVIEW FIEL
struct DocumentViewerView_Previews: PreviewProvider {
    static var previews: some View {
        DocumentViewerView(
            url: "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
            title: "Factura B001-0002491",
            xmlUrl: "https://example.com/xml"
        )
    }
}
