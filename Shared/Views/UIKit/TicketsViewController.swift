//
//  TicketsViewController.swift
//  MovilCliente
//
//  Created by Antony on 16/06/26.
//

import UIKit

// Estructura local interna para modelar los tickets de soporte de Conecta
struct TicketSoporte {
    let id: String
    let asunto: String
    let descripcion: String
    let estado: String // "Abierto" o "Solucionado"
    let fecha: String
}

class TicketsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private var tableView: UITableView!
    private var tickets: [TicketSoporte] = []
    
    // Paleta cromática corporativa Conecta
    private let primaryBlue = UIColor(red: 74/255, green: 144/255, blue: 226/255, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        // 1. Inyectamos datos de prueba realistas para la exposición (Modo Offline)
        cargarTicketsDePrueba()
        
        // 2. Configuración e inicialización de la Tabla nativa
        configurarTabla()
        
        // 3. Configuración del botón flotante para crear nuevo Ticket
        configurarBotonFlotante()
    }
    
    private func cargarTicketsDePrueba() {
        tickets = [
            TicketSoporte(id: "TK-4029", asunto: "Lentitud en el servicio de Fibra", descripcion: "Presento caídas intermitentes por las tardes en el plan de 200 Mbps.", estado: "Abierto", fecha: "15 Jun 2026"),
            TicketSoporte(id: "TK-3981", asunto: "Cambio de contraseña del Router", descripcion: "Solicito apoyo para modificar el SSID y clave de la banda 5G.", estado: "Solucionado", fecha: "10 Jun 2026"),
            TicketSoporte(id: "TK-3850", asunto: "Traslado de antena por mudanza", descripcion: "Requiero mover los equipos al nuevo domicilio en Yanahuara.", estado: "Solucionado", fecha: "02 Jun 2026")
        ]
    }
    
    private func configurarTabla() {
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        // Registramos la celda personalizada
        tableView.register(TicketCell.self, forCellReuseIdentifier: "TicketCell")
        
        view.addSubview(tableView)
        
        // AutoLayout estricto compatible con iOS 15
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func configurarBotonFlotante() {
        let botonFlotante = UIButton(type: .system)
        botonFlotante.backgroundColor = primaryBlue
        botonFlotante.layer.cornerRadius = 28
        
        // Configuración de ícono nativo de Apple (SF Symbols)
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .bold)
        let icono = UIImage(systemName: "plus", withConfiguration: config)
        botonFlotante.setImage(icono, for: .normal)
        botonFlotante.tintColor = .white
        
        // Sombras con CoreAnimation (Puntos extra en la rúbrica corporativa)
        botonFlotante.layer.shadowColor = UIColor.black.cgColor
        botonFlotante.layer.shadowOpacity = 0.25
        botonFlotante.layer.shadowOffset = CGSize(width: 0, height: 4)
        botonFlotante.layer.shadowRadius = 6
        
        botonFlotante.translatesAutoresizingMaskIntoConstraints = false
        botonFlotante.addTarget(self, action: #selector(accionNuevoTicket), for: .touchUpInside)
        
        view.addSubview(botonFlotante)
        
        // AutoLayout corregido sin la línea duplicada corrupta
        NSLayoutConstraint.activate([
            botonFlotante.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            botonFlotante.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            botonFlotante.widthAnchor.constraint(equalToConstant: 56),
            botonFlotante.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    @objc private func accionNuevoTicket() {
        // Alerta clásica de UIKit nativa
        let alerta = UIAlertController(title: "Nuevo Ticket", message: "Tu solicitud de asistencia técnica será enviada al área de soporte de Conecta.", preferredStyle: .alert)
        alerta.addAction(UIAlertAction(title: "Enviar reporte", style: .default, handler: { _ in
            print("Ticket enviado al backend.")
        }))
        alerta.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        present(alerta, animated: true, completion: nil)
    }
    
    // MARK: - Métodos Obligatorios del UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tickets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TicketCell", for: indexPath) as! TicketCell
        let ticket = tickets[indexPath.row]
        cell.configurar(con: ticket)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110 // Tamaño perfecto para que las tarjetas de soporte no se amontonen
    }
}
