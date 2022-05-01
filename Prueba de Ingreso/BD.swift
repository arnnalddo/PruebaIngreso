//
//  BD.swift
//  Prueba de Ingreso
//
//  Created by Arnaldo Alfredo on 2022-04-29.
//
//*********************************************************************
// Esta clase, servirá para realizar la conexión con la base
// de datos local, haciendo uso de la librería SQLite.
// Además, permite registrar y obtener los datos necesarios
// de los usuarios.
//*********************************************************************

import Foundation
import SQLite

class BD {
    
    //*****************************************************************
    // MARK: - Propiedades
    //*****************************************************************
    private var bd: Connection!// instancia de la Base de Datos SQLite
    // instancias de la tabla USUARIO y sus columnas:
    private var tablaUsuario: Table!
    private var id: Expression<Int64>!
    private var nombre: Expression<String>!
    private var correo: Expression<String>!
    private var telefono: Expression<String>!
    
    //*****************************************************************
    // MARK: - Constructores
    //*****************************************************************
    init () {
        do {
            // directorio principal de almacenamiento:
            let dir:String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
            // creo la conexion con la base de datos:
            bd = try Connection("\(dir)/usuarios.sqlite3")
            // creo el objeto de la tabla para los usuarios:
            tablaUsuario = Table("USUARIO")
            // creo las instancias para cada columna de la tabla:
            id = Expression<Int64>("id")
            nombre = Expression<String>("nombre")
            correo = Expression<String>("correo")
            telefono = Expression<String>("telefono")
            
            // Si la tabla USUARIO aún no existe...
            if (!UserDefaults.standard.bool(forKey: "existeTablaUsuarioBD")) {
                // ...entonces intento crearla...
                try bd.run(tablaUsuario.create { (t) in
                    t.column(id, primaryKey: true)
                    t.column(nombre)
                    t.column(correo, unique: true)
                    t.column(telefono)
                })
                // ...y guardo en el dispositivo el valor "true" para saber que no es
                // necesario volver a crear la tabla
                UserDefaults.standard.set(true, forKey: "existeTablaUsuarioBD")
            }
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    //*****************************************************************
    // MARK: - Funciones principales
    //*****************************************************************
    // Agregar usuario a la Base de Datos:
    public func agregarUsuario(valorNombre: String, valorCorreo: String, valorTelefono: String) {
        do {
            try bd.run(tablaUsuario.insert(nombre <- valorNombre, correo <- valorCorreo, telefono <- valorTelefono))
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // Obtener lista de usuarios desde la Base de Datos:
    public func traerUsuarios() -> [ModeloUsuario] {
        // creo una matriz vacía
        var usuarios: [ModeloUsuario] = []
        // obtengo la lista de todos los usuarios en orden ascendiente
        tablaUsuario = tablaUsuario.order(id.asc)
        
        do {
            // encuentro cada uno de los usuarios a través de un bucle
            for u in try bd.prepare(tablaUsuario) {
                // y lo voy agregando a la matriz
                usuarios.append(ModeloUsuario(id: Int(u[id]), name: u[nombre], email: u[correo], phone: u[telefono]))
            }
        } catch {
            print(error.localizedDescription)
        }
     
        // Finalmente, devuelvo la lista de todos los usuarios (si hay)
        return usuarios
    }
    
}
