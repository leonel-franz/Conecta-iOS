//
//  TicketCell.swift
//  MovilCliente
//
//  Created by Antony on 16/06/26.
//

import Foundation
import UIKit

class TicketCell: UITableViewCell {
    
    private let tarjetaFondo = UIView()
    private let etiquetaAsunto = UILabel()
    private let etiquetaCodigo = UILabel()
    private let etiquetaFecha = UILabel()
    private let contenedorBadge = UIView()
    private let etiquetaEstado = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        
        configurarDisenoCapa()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configurarDisenoCapa() {
        // Tarjeta contenedora blanca con bordes curvos tipo React Native Card
        tarjetaFondo.backgroundColor = .secondarySystemGroupedBackground
        tarjetaFondo.layer.cornerRadius = 16
        tarjetaFondo.layer.shadowColor = UIColor.black.cgColor
        tarjetaFondo.layer.shadowOpacity = 0.03
        tarjetaFondo.layer.shadowOffset = CGSize(width: 0, height: 2)
        tarjetaFondo.layer.shadowRadius = 4
        tarjetaFondo.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(tarjetaFondo)
        
        etiquetaAsunto.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        etiquetaAsunto.textColor = .label
        etiquetaAsunto.translatesAutoresizingMaskIntoConstraints = false
        tarjetaFondo.addSubview(etiquetaAsunto)
        
        etiquetaCodigo.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        etiquetaCodigo.textColor = .secondaryLabel
        etiquetaCodigo.translatesAutoresizingMaskIntoConstraints = false
        tarjetaFondo.addSubview(etiquetaCodigo)
        
        etiquetaFecha.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        etiquetaFecha.textColor = .tertiaryLabel
        etiquetaFecha.translatesAutoresizingMaskIntoConstraints = false
        tarjetaFondo.addSubview(etiquetaFecha)
        
        // Badge de estado curvo
        contenedorBadge.layer.cornerRadius = 6
        contenedorBadge.translatesAutoresizingMaskIntoConstraints = false
        tarjetaFondo.addSubview(contenedorBadge)
        
        etiquetaEstado.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        etiquetaEstado.translatesAutoresizingMaskIntoConstraints = false
        contenedorBadge.addSubview(etiquetaEstado)
        
        // AutoLayout estricto para posicionar los elementos adentro de la celda
        NSLayoutConstraint.activate([
            tarjetaFondo.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            tarjetaFondo.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tarjetaFondo.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            tarjetaFondo.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            etiquetaAsunto.topAnchor.constraint(equalTo: tarjetaFondo.topAnchor, constant: 14),
            etiquetaAsunto.leadingAnchor.constraint(equalTo: tarjetaFondo.leadingAnchor, constant: 16),
            etiquetaAsunto.trailingAnchor.constraint(equalTo: contenedorBadge.leadingAnchor, constant: -12),
            
            etiquetaCodigo.topAnchor.constraint(equalTo: etiquetaAsunto.bottomAnchor, constant: 4),
            etiquetaCodigo.leadingAnchor.constraint(equalTo: tarjetaFondo.leadingAnchor, constant: 16),
            
            etiquetaFecha.bottomAnchor.constraint(equalTo: tarjetaFondo.bottomAnchor, constant: -12),
            etiquetaFecha.leadingAnchor.constraint(equalTo: tarjetaFondo.leadingAnchor, constant: 16),
            
            contenedorBadge.trailingAnchor.constraint(equalTo: tarjetaFondo.trailingAnchor, constant: -16),
            contenedorBadge.centerYAnchor.constraint(equalTo: tarjetaFondo.centerYAnchor),
            contenedorBadge.heightAnchor.constraint(equalToConstant: 24),
            
            etiquetaEstado.topAnchor.constraint(equalTo: contenedorBadge.topAnchor, constant: 4),
            etiquetaEstado.bottomAnchor.constraint(equalTo: contenedorBadge.bottomAnchor, constant: -4),
            etiquetaEstado.leadingAnchor.constraint(equalTo: contenedorBadge.leadingAnchor, constant: 8),
            etiquetaEstado.trailingAnchor.constraint(equalTo: contenedorBadge.trailingAnchor, constant: -8)
        ])
    }
    
    func configurar(con ticket: TicketSoporte) {
        etiquetaAsunto.text = ticket.asunto
        etiquetaCodigo.text = ticket.id
        etiquetaFecha.text = "Reportado el: \(ticket.fecha)"
        etiquetaEstado.text = ticket.estado.uppercased()
        
        if ticket.estado == "Abierto" {
            etiquetaEstado.textColor = .systemOrange
            contenedorBadge.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.12)
        } else {
            etiquetaEstado.textColor = .systemGreen
            contenedorBadge.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.12)
        }
    }
}
