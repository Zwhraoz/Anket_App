//
//  ContentView.swift
//  Anket_App
//
//  Created by zehra özer on 18.05.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject var authVM = AuthViewModel()
    
    var body: some View {
        Group {
            if authVM.isLoggedIn {
                // Check if userId exists when showing MainTabView
                if let userId = UserDefaults.standard.object(forKey: "userId") {
                MainTabView()
                    .environmentObject(authVM)
                } else {
                    // If userId is missing but isLoggedIn is true, we have an inconsistent state
                    Text("Oturum bilgisi eksik. Lütfen tekrar giriş yapın.")
                        .padding()
                        .onAppear {
                            print("WARNING: isLoggedIn true but no userId found")
                            // Reset login state
                            authVM.isLoggedIn = false
                        }
                }
            } else {
                LoginView()
                    .environmentObject(authVM)
            }
        }
    }
}

