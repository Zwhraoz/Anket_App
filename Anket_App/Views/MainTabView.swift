//
//  MainTabView.swift
//  Anket_App
//
//  Created by zehra özer on 18.05.2025.
//

import SwiftUI


struct MainTabView: View {
    var body: some View {
        TabView {
            SurveyListView()
                .tabItem {
                    Label("Anketler", systemImage: "doc.plaintext")
                }

            SettingsView()
                .tabItem {
                    Label("Ayarlar", systemImage: "gear")
                }
        }
    }
}


#Preview {
    MainTabView()
}
