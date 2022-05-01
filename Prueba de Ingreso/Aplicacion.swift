//
//  Aplicacion.swift
//  Prueba de Ingreso
//
//  Created by Arnaldo Alfredo on 2022-04-29.
//

import SwiftUI

@main
struct Aplicacion: App {
    var body: some Scene {
        WindowGroup {
            Usuarios()
                .accentColor(Color(.systemGreen))// Color(red: 0.11, green: 0.37, blue: 0.13, alpha: 1.0) (el verde de Material Design)
                .navigationViewStyle(.stack)
        }
    }
}
