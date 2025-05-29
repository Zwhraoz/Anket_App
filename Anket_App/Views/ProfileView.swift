//
//  ProfileView.swift
//  Anket_App
//
//  Created by zehra özer on 18.05.2025.
//

import SwiftUI

struct ProfileView: View {
    @State private var username: String = "Kullanıcı"
    @State private var email: String = "email@example.com"
    
    var body: some View {
        Form {
            Section(header: Text("Profil Bilgileri")) {
                TextField("Kullanıcı Adı", text: $username)
                TextField("E-posta", text: $email)
                    .keyboardType(.emailAddress)
            }
            
            Section {
                Button("Kaydet") {
                    // Kaydetme işlemi (örneğin UserDefaults veya CoreData)
                    print("Profil kaydedildi: \(username), \(email)")
                }
                .foregroundColor(.blue)
            }
        }
        .navigationTitle("Profil")
    }
}

