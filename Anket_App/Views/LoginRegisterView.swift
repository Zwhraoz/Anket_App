//
//  LoginRegisterView.swift
//  Anket_App
//
//  Created by zehra özer on 18.05.2025.
//
import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var navigateToRegister = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 30) {
                    Spacer()
                    
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .foregroundColor(.white)
                        .shadow(radius: 10)

                    Text("Hoş Geldiniz")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "envelope")
                                .foregroundColor(.gray)
                            TextField("Email", text: $email)
                                .autocapitalization(.none)
                                .foregroundColor(.black)

                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: .gray.opacity(0.3), radius: 5)

                        HStack {
                            Image(systemName: "lock")
                                .foregroundColor(.gray)
                            SecureField("Şifre", text: $password)
                                .foregroundColor(.black)

                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: .gray.opacity(0.3), radius: 5)
                    }
                    .padding(.horizontal)

                    Button(action: {
                        // Basit demo amaçlı giriş kontrolü
                        if !email.isEmpty && !password.isEmpty {
                            authVM.isLoggedIn = true
                        }
                    }) {
                        Text("Giriş Yap")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.purple)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                    }
                    .padding(.horizontal)

                    HStack {
                        Spacer()
                        Button("Şifremi Unuttum?") {
                            // Şifre sıfırlama
                        }
                        .foregroundColor(.white)
                        .font(.footnote)
                    }
                    .padding(.horizontal)

                    Spacer()

                    HStack {
                        Text("Hesabınız yok mu?")
                            .foregroundColor(.white)
                        Button("Kayıt Ol") {
                            navigateToRegister = true
                        }
                        .foregroundColor(.white)
                        .bold()
                    }
                    .padding(.bottom)

                    NavigationLink(destination: RegisterView(), isActive: $navigateToRegister) {
                        EmptyView()
                    }
                }
                .padding()
            }
        }
    }
}

#Preview {
    LoginView()
}
