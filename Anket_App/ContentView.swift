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
                MainTabView()
                    .environmentObject(authVM)
            } else {
                LoginView()
                    .environmentObject(authVM)
            }
        }
    }
}

