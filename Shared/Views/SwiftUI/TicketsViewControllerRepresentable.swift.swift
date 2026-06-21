//
//  TicketsViewControllerRepresentable.swift.swift
//  MovilCliente
//
//  Created by Antony on 16/06/26.
//



import SwiftUI
import UIKit


struct TicketsViewControllerRepresentable: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = TicketsViewController
    

    func makeUIViewController(context: Context) -> TicketsViewController {
        return TicketsViewController()
    }
    
    func updateUIViewController(_ uiViewController: TicketsViewController, context: Context) {

    }
}
