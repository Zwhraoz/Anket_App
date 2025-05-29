//
//  RegisterView.swift
//  Anket_App
//
//  Created by zehra özer on 18.05.2025.
//

import SwiftUI

struct RegisterView: View {
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var navigateToLogin = false
    
    @State private var showAlert = false
    @State private var alertMessage = ""

    func registerUser() {
        // Basit doğrulamalar
        guard !email.isEmpty, !password.isEmpty else {
            alertMessage = "Email ve şifre boş olamaz"
            showAlert = true
            return
        }
        guard password == confirmPassword else {
            alertMessage = "Şifreler eşleşmiyor"
            showAlert = true
            return
        }
        
        // User modeli oluştur
        let user = User(mail: email, password: password)
        
        // AuthService ile kayıt işlemi
        AuthService.shared.register(user: user) { success, message in
            DispatchQueue.main.async {
                if success {
                    alertMessage = "Kayıt başarıyla oluştu!"
                    showAlert = true
                    // Başarılı alertten sonra login sayfasına yönlendirme
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        navigateToLogin = true
                    }
                } else {
                    alertMessage = "Kayıt başarısız: \(message)"
                    showAlert = true
                }
            }
        }
    }

    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.purple.opacity(0.8), Color.blue.opacity(0.8)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 28) {
                    Spacer()

                    Image(systemName: "person.crop.circle.badge.plus")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.white)
                        .shadow(radius: 10)

                    Text("Kayıt Ol")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)

                    VStack(spacing: 16) {
                        CustomInputField(systemImage: "person", placeholder: "Ad Soyad", text: $name)
                        CustomInputField(systemImage: "envelope", placeholder: "Email", text: $email)
                        CustomInputField(systemImage: "lock", placeholder: "Şifre", text: $password, isSecure: true)
                        CustomInputField(systemImage: "lock.rotation", placeholder: "Şifreyi Onayla", text: $confirmPassword, isSecure: true)
                    }
                    .padding(.horizontal)

                    Button(action: {
                        registerUser()
                    }) {
                        Text("Kayıt Ol")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.purple)
                            .font(.headline)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                    }
                    .padding(.horizontal)

                    Spacer()

                    HStack {
                        Text("Zaten bir hesabın var mı?")
                            .foregroundColor(.white)
                        Button("Giriş Yap") {
                            navigateToLogin = true
                        }
                        .foregroundColor(.white)
                        .bold()
                    }
                    .padding(.bottom)

                    // Gizli NavigationLink, navigateToLogin true olunca LoginView'a gider
                    NavigationLink(destination: LoginView(), isActive: $navigateToLogin) {
                        EmptyView()
                    }
                }
                .padding()
            }
        }
        .alert(alertMessage, isPresented: $showAlert) {
            Button("Tamam") { }
        }
    }
}

struct CustomInputField: View {
    var systemImage: String
    var placeholder: String
    @Binding var text: String
    var isSecure: Bool = false

    var body: some View {
        HStack {
            Image(systemName: systemImage)
                .foregroundColor(.gray)

            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
                    .autocapitalization(.none)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.3), radius: 5)
    }
}
