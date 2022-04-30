//
//  Publicaciones.swift
//  Prueba de Ingreso
//
//  Created by Arnaldo Alfredo on 2022-04-29.
//

import SwiftUI

// Estructura de la API (Posts)
struct ModeloPublicacion: Codable {
    var id: Int
    var title: String
    var body: String
}

struct Publicaciones: View {
    
    //*****************************************************************
    // MARK: - Propiedades
    //*****************************************************************
    @Binding var usuarioActual: ModeloUsuario// para obtener los datos del usuario
    @State private var publicaciones = [ModeloPublicacion]()// para obtener todas las publicaciones del usuario
    @State private var enCarga = false// para saber si se está cargando o no el contenido
    
    //*****************************************************************
    // MARK: - Cuerpo
    //*****************************************************************
    var body: some View {
        ZStack {
            // Lista de publicaciones del usuario
            List {
                // ----------------------------------------------------
                // Tarjeta: Detalles del usuario:
                // ----------------------------------------------------
                VStack(alignment: .leading) {
                    Text(usuarioActual.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Label(usuarioActual.email, systemImage: "mail")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, -4)
                    Label(usuarioActual.phone, systemImage: "phone")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, -4)
                    HStack {
                        Spacer()
                        Spacer()
                    }
                }
                .padding([.top, .bottom, .horizontal])
                .background(Color(.tertiarySystemBackground))
                .cornerRadius(6)
                .shadow(color: .black.opacity(0.12), radius: 0, x: 0, y: 2)
                .listRowSeparator(.hidden)
                .listRowBackground(EmptyView())
                
                // ----------------------------------------------------
                // Tarjetas: Cada una de las Publicaciones del usuario:
                // ----------------------------------------------------
                ForEach (publicaciones, id: \.id) { p in
                    VStack(alignment: .leading) {
                        Text(p.title)
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text(p.body)
                            .font(.body)
                            .foregroundColor(.secondary)
                        HStack {
                            Spacer()
                            Spacer()
                        }
                    }
                    .padding([.top, .bottom, .horizontal])
                    .background(Color(.tertiarySystemBackground))
                    .cornerRadius(6)
                    .shadow(color: .black.opacity(0.12), radius: 0, x: 0, y: 2)
                    .listRowSeparator(.hidden)
                    .listRowBackground(EmptyView())
                }
            }
            .navigationTitle("Publicaciones")
            .listStyle(GroupedListStyle())
            .onAppear() {
                enCarga = true
            }
            .task {
                await cargarDatos()
            }
            
            if enCarga {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .secondary))
            }
        }
    }
    
    //*****************************************************************
    // MARK: - Funciones principales
    //*****************************************************************
    // Cargar contenido desde la API
    private func cargarDatos() async {
        let urlStr = "https://jsonplaceholder.typicode.com/posts?userId=\(usuarioActual.id)"
        // Voy a intentar cargar las publicaciones desde la API en el servidor
        guard let url = URL(string: urlStr) else {
            enCarga = false
            print("URL no válida")
            return
        }
        do {
            print("Cargando datos desde: \(urlStr)")
            // Cargo los datos desde la API
            let (datoJson, _) = try await URLSession.shared.data(from: url)
            // Decodifico el contenido...
            let decoder = JSONDecoder()
            if let json = try? decoder.decode([ModeloPublicacion].self, from: datoJson) {
                // ...y almaceno el resultado en la varioable "publicaciones" para que pueda
                // usarse en toda esta Vista
                publicaciones = json
                enCarga = false
                print("Datos cargados con éxito desde la API")
            }
            
        } catch {
            enCarga = false
            print("Error al cargar los datos \(error.localizedDescription)")
        }
        
    }
    
}

struct Publicaciones_Previews: PreviewProvider {
    static var previews: some View {
        Publicaciones(usuarioActual: .constant(ModeloUsuario(id: 0, name: "", email: "", phone: "")))
    }
}
