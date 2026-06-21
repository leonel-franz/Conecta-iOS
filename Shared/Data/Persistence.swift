//
//  Persistence.swift
//  MovilCliente
//
//  Created by Leonel on 16/06/26.
//

import CoreData

struct PersistenceController {
    // MARK: - Singleton Estándar
    /// Instancia compartida única para ser utilizada en toda la infraestructura de la aplicación.
    static let shared = PersistenceController()

    // MARK: - Contenedor Persistente
    /// El contenedor que gestiona el modelo de datos, el coordinador de almacenamiento y el contexto.
    let container: NSPersistentContainer

    // MARK: - Inicializador Base
    /// Inicializa el controlador de Core Data y carga los almacenes físicos en el disco.
    /// - Parameter inMemory: Si es verdadero, los datos se guardan temporalmente en la memoria RAM (útil para pruebas unitarias o Previews).
    init(inMemory: Bool = false) {
        // Vinculamos el contenedor con el archivo .xcdatamodeld llamado "MovilCliente"
        container = NSPersistentContainer(name: "MovilCliente")

        if inMemory {
            // Configuramos el almacén para que apunte a /dev/null, forzando la persistencia temporal en RAM
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        // Cargamos los almacenes persistentes asíncronamente
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                /*
                 RECOMENDACIÓN SENIOR PARA LA SUSTENTACIÓN:
                 En una aplicación real, los errores aquí se deben reportar a un sistema de analíticas.
                 Los fallos comunes incluyen: falta de espacio en disco, permisos denegados o que el modelo
                 haya cambiado sin realizar una migración de base de datos previa (Migration).
                 */
                print("Error crítico al inicializar Core Data: \(error), \(error.userInfo)")
                
                // Mantenemos un comportamiento seguro o fallback en producción para evitar crasheos innecesarios
                #if DEBUG
                fatalError("Error no resuelto en Core Data: \(error.localizedDescription)")
                #endif
            }
        }
        
        // Configuración de fusión automática de cambios entre diferentes hilos de ejecución
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
    }

    // MARK: - Instancia exclusiva para Previews de SwiftUI (Canvas)
    /// Proveedor de entorno de pruebas con datos ficticios inyectados directamente en memoria.
    /// Evita escrituras reales en el almacenamiento del dispositivo y optimiza el rendimiento en la Máquina Virtual.
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext

        // MARK: - INYECCIÓN DE ENTIDADES DE PRUEBA (Opcional)
        /*
         Aquí puedes inicializar entidades ficticias si ya creaste tus clases de Core Data.
         Por ejemplo, si tienes una entidad llamada 'UserEntity':
         
         let newUser = UserEntity(context: viewContext)
         newUser.id = "usr_preview_1"
         newUser.email = "pepito.perez@conecta.com"
         */

        do {
            // Guardamos el contexto temporal en memoria RAM para alimentar al Canvas
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print("Error al generar datos de prueba para el Preview: \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
}
