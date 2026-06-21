//
//  MapView.swift
//  MovilCliente
//
//  Created by Antony on 16/06/26.
//

import SwiftUI
import MapKit

// Estructura de paridad para el marcador del abonado Conecta
struct ServiceLocation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let address: String
}

struct MapView: View {
    @Environment(\.dismiss) var dismiss
    
    // Parámetros dinámicos equivalentes a tus useLocalSearchParams
    let lat: Double
    let lng: Double
    let addressText: String
    
    // Región de enfoque inicial del mapa (Equivalente al zoom: 16 de tu código)
    @State private var region: MKCoordinateRegion
    private let locations: [ServiceLocation]
    
    // Paleta de identidad corporativa Conecta
    private let primaryColor = Color(red: 0.17, green: 0.62, blue: 0.70) // #2B9EB3
    private let gradientStart = Color(red: 74/255, green: 144/255, blue: 226/255)
    
    // Inicializador para procesar la geolocalización de forma idéntica a tus parseFloat
    init(lat: Double, lng: Double, addressText: String) {
        self.lat = lat
        self.lng = lng
        self.addressText = addressText
        
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        self._region = State(initialValue: MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        ))
        self.locations = [ServiceLocation(coordinate: coordinate, address: addressText)]
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            // MARK: - Header Premium con Gradiente de Identidad
            LinearGradient(gradient: Gradient(colors: [gradientStart, primaryColor]), startPoint: .leading, endPoint: .trailing)
                .frame(height: 90)
                .overlay(
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(Color.white.opacity(0.2))
                                .clipShape(Circle())
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Ubicación")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            Text("Dirección de instalación")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 30),
                    alignment: .top
                )
                .ignoresSafeArea(.all, edges: .top)
            
            // MARK: - Mapa Interactivo con MapKit Nativo (Sin WebViews lentos)
            Map(coordinateRegion: $region, annotationItems: locations) { item in
                MapAnnotation(coordinate: item.coordinate) {
                    // Custom Pin con el Gradiente Fibertel/Conecta calzado de tu css Leaflet
                    VStack(spacing: 0) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(gradient: Gradient(colors: [gradientStart, primaryColor]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 44, height: 44)
                                .shadow(color: gradientStart.opacity(0.4), radius: 6, x: 0, y: 4)
                            
                            Image(systemName: "mappin")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        // Flecha indicadora inferior del pin
                        Image(systemName: "triangle.fill")
                            .resizable()
                            .frame(width: 10, height: 6)
                            .foregroundColor(primaryColor)
                            .rotationEffect(.degrees(180))
                            .offset(y: -2)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // MARK: - Banner Inferior de Dirección con Animación Nativa
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(primaryColor.opacity(0.1))
                            .frame(width: 44, height: 44)
                        Image(systemName: "mappin.and.ellipse")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(primaryColor)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(addressText)
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                            .lineLimit(2)
                        
                        Text(String(format: "%.6f, %.6f", lat, lng))
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(24, corners: [.topLeft, .topRight])
            .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: -4)
        }
        .navigationBarHidden(true)
    }
}

// MARK: - EXTENSIÓN ÚTIL PARA REDONDEAR ESQUINAS ESPECÍFICAS
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }	
}

// MARK: - PREVIEW FIEL CON COORDENADAS DE PRUEBA (MOCK)
struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(lat: -12.046374, lng: -77.042793, addressText: "Av. Las Flores 452, San Isidro, Lima")
    }
}
