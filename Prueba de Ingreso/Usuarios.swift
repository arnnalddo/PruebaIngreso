//
//  Usuarios.swift
//  Prueba de Ingreso
//
//  Created by Arnaldo Alfredo on 2022-04-29.
//

import SwiftUI

// Estructura de la API (Users)
struct ModeloUsuario: Codable {
    var id: Int
    var name: String
    var email: String
    var phone: String
}

//*********************************************************************
// Esta es la estructura principal, donde se muestra
// la lista de los usuarios.
//*********************************************************************
struct Usuarios: View {
    
    //*****************************************************************
    // MARK: - Propiedades
    //*****************************************************************
    @State private var usuarios = [ModeloUsuario]()// donde se almacena la lista de usuarios ya en formato "usable" (obtenida desde la API o la BD local)
    @State private var usuarioActual = ModeloUsuario(id: 0, name: "", email: "", phone: "")// usuario elegido
    @State private var detalleAbierto = false// para saber si se abrió o no el detalle (ver publicaciones)
    @State private var enCarga = false// para saber si se está cargando o no el contenido
    @State private var txtBusqueda = ""// el texto que el usuario ingrese en el campo de búsqueda
    // Para filtrar los usuarios por nombre, según la búsqueda:
    private var filtroBusqueda: [ModeloUsuario] {
        if txtBusqueda.isEmpty {
            return usuarios
        } else {
            return usuarios.filter {
                $0.name.localizedCaseInsensitiveContains(txtBusqueda)
            }
        }
    }
    
    //*****************************************************************
    // MARK: - Cuerpo
    //*****************************************************************
    var body: some View {
        NavigationView {
            ZStack {
                // Lista principal de usuarios:
                List(filtroBusqueda, id: \.id){ u in
                    // ------------------------------------------------
                    // Tarjeta: en la que se muestran...
                    // ------------------------------------------------
                    VStack(alignment: .leading) {
                        Text(u.name)// ...el nombre del usuario,
                            .font(.headline)
                            .foregroundColor(.primary)
                        Label(u.email, systemImage: "mail")// su dirección de correo electrónico,
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, -4)
                        Label(u.phone, systemImage: "phone")// su número de teléfono...
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, -4)
                        // ...y también un botón para visualizar sus publicaciones:
                        HStack {// (para ordenar horizontalmente)
                            Spacer()// (para dividir en dos columnas y posicionar el botón a la derecha)
                            Button(action: {
                                // Se pulsó el botón, actualizo el valor de las banderas:
                                usuarioActual = ModeloUsuario(id: u.id, name: u.name, email: u.email, phone: u.phone)
                                detalleAbierto = true
                            }, label: {
                                Text("Ver Publicaciones →")
                                    .textCase(.uppercase)
                                    .font(.caption.bold())
                            })
                            // aplico estilo al botón:
                            .buttonStyle(BorderlessButtonStyle())// impide que toda la tarjeta sea "clickable"
                            .padding(.vertical)
                        }
                    }// fin VStack (tarjeta)
                    // aplico estilo a la "tarjeta" o ítem de la lista:
                    .padding([.top, .horizontal])
                    .background(Color(.tertiarySystemBackground))
                    .cornerRadius(6)
                    .shadow(color: .black.opacity(0.12), radius: 0, x: 0, y: 2)
                    .listRowSeparator(.hidden)
                    .listRowBackground(EmptyView())
                }// fin List
                // Configuro la lista:
                .listStyle(GroupedListStyle())
                .searchable(text: $txtBusqueda, prompt: "Buscar usuario")
                .task { await cargarDatos() }// tarea para cargar los datos, antes de mostrar la lista
                // ----------------------------------------------------
                // "Rueda" de progreso || Mensaje de lista vacía:
                // ----------------------------------------------------
                // Siempre que se esté cargando el contenido, se va a mostrar un indicador:
                if enCarga {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .secondary))
                } else if filtroBusqueda.isEmpty {
                    // Y siempre que el filtro de búsqueda no corresponde con ningún usuario, debe aparecer el mensaje “List is empty”:
                    Text("List is empty")
                        .foregroundColor(.secondary)
                }
                // ----------------------------------------------------
                // Enlace: acción al pulsar el botón de la "tarjeta":
                // ----------------------------------------------------
                NavigationLink(destination: Publicaciones(usuarioActual: $usuarioActual), isActive: $detalleAbierto) { EmptyView() }
                    .isDetailLink(false)
            }// fin ZStack
            .navigationTitle("Usuarios")
            .onAppear() { enCarga = true }
        }// fin NavigationView
    }
    
    //*****************************************************************
    // MARK: - Funciones principales
    //*****************************************************************
    // Cargar contenido (desde la API o desde la base de datos local)
    private func cargarDatos() async {
        let urlStr = "https://jsonplaceholder.typicode.com/users"
        // Verifico si los datos de los usuarios se encuentran almacenados en la BD local
        usuarios = BD().traerUsuarios();
        // En el caso de que haya registro en la base de datos local:
        if !usuarios.isEmpty {
            enCarga = false
            print("Hay usuarios en la base de datos local, listarlos desde ahí...")
            return
        } else {
            // Si no, pues voy a intentar cargar desde la API en el servidor
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
                if let json = try? decoder.decode([ModeloUsuario].self, from: datoJson) {
                    print("Datos cargados con éxito desde la API. Guardando en la base de datos local...")
                    // ...y guardo en la base de datos local, los datos de cada usuario
                    for dato in json {
                        BD().agregarUsuario(valorNombre: dato.name, valorCorreo: dato.email, valorTelefono: dato.phone)
                    }
                    // Además, guardo en la varioable "usuarios" para usar ya en esta pantalla:
                    usuarios = json
                    enCarga = false
                }
                
            } catch {
                enCarga = false
                print("Error al cargar los datos \(error.localizedDescription)")
            }
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Usuarios()
            .previewInterfaceOrientation(.portrait)
    }
}
