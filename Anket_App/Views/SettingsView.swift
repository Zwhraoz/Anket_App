import SwiftUI
import MessageUI

// SettingsView - Ayarlar ekranı
struct SettingsView: View {
    @AppStorage("userName") var userName: String = "Kullanıcı Adı"
    @AppStorage("userEmail") var userEmail: String = "kullanici@example.com"
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    @AppStorage("appLanguage") var appLanguage: String = "Türkçe"
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = true
    @EnvironmentObject var authVM: AuthViewModel


    @State private var isEditingProfile = false
    @State private var tempName = ""
    @State private var tempEmail = ""
    @State private var showResetAlert = false
    @State private var showMailComposer = false
    
    let languages = ["Türkçe", "English", "Deutsch"]
    
    var body: some View {
        NavigationView {
            Form {
                // PROFIL
                Section(header: Text("Profil")) {
                    HStack(spacing: 15) {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(userName)
                                .font(.headline)
                            Text(userEmail)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            tempName = userName
                            tempEmail = userEmail
                            isEditingProfile = true
                        }) {
                            Image(systemName: "pencil")
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                // GÖRÜNÜM
                Section(header: Text("Görünüm")) {
                    Toggle("Koyu Mod", isOn: $isDarkMode)
                    Picker("Uygulama Dili", selection: $appLanguage) {
                        ForEach(languages, id: \.self) { lang in
                            Text(lang)
                        }
                    }
                }
                
                // BİLDİRİMLER
                Section(header: Text("Bildirimler")) {
                    Toggle("Anket Hatırlatmaları", isOn: .constant(true))
                    Toggle("Yeni Özellikler", isOn: .constant(false))
                }
                
                // DESTEK & İLETİŞİM
                Section(header: Text("Yardım ve Destek")) {
                    Button {
                        showMailComposer = true
                    } label: {
                        Label("Bize Ulaşın", systemImage: "envelope.fill")
                    }
                    
                    NavigationLink(destination: AboutView()) {
                        Label("Hakkında", systemImage: "info.circle.fill")
                    }
                }
                
                // VERİLER
                Section(header: Text("Veri Yönetimi")) {
                    Button(role: .destructive) {
                        showResetAlert = true
                    } label: {
                        Label("Tüm Verileri Sıfırla", systemImage: "trash.fill")
                    }
                }
                
                // ÇIKIŞ
                Section {
                    Button(role: .destructive) {
                        signOut()
                    } label: {
                        Label("Çıkış Yap", systemImage: "arrow.backward.square")
                    }
                }
                
                // SÜRÜM
                Section {
                    HStack {
                        Text("Sürüm")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Ayarlar")
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .sheet(isPresented: $isEditingProfile) {
            profileEditSheet
        }
        .alert("Tüm veriler silinsin mi?", isPresented: $showResetAlert) {
            Button("Evet", role: .destructive) {
                resetAppData()
            }
            Button("İptal", role: .cancel) { }
        } message: {
            Text("Bu işlem geri alınamaz!")
        }
    }
    
    private var profileEditSheet: some View {
        NavigationView {
            Form {
                Section(header: Text("Ad Soyad")) {
                    TextField("Ad Soyad", text: $tempName)
                }
                Section(header: Text("E-posta")) {
                    TextField("E-posta", text: $tempEmail)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
            }
            .navigationTitle("Profili Düzenle")
            .navigationBarItems(
                leading: Button("İptal") {
                    isEditingProfile = false
                },
                trailing: Button("Kaydet") {
                    userName = tempName
                    userEmail = tempEmail
                    isEditingProfile = false
                }
            )
        }
    }
    
    private func resetAppData() {
        userName = "Kullanıcı Adı"
        userEmail = "kullanici@example.com"
        appLanguage = "Türkçe"
        isDarkMode = false
        // Gerekirse diğer veriler de sıfırlanabilir
    }
    
    private func signOut() {
        // Kullanıcı bilgilerini sıfırla
        userName = "Kullanıcı Adı"
        userEmail = "kullanici@example.com"
        appLanguage = "Türkçe"
        isDarkMode = false
        
        // Giriş durumunu false yaparak login ekranına dön
        isLoggedIn = false
    }
}

// Hakkında sayfası
struct AboutView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "info.circle.fill")
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundColor(.blue)
            Text("Anket App")
                .font(.largeTitle)
            Text("Bu uygulama kullanıcıların anketleri görüntülemesini ve yönetmesini sağlar. Veriler güvenle saklanır.")
                .multilineTextAlignment(.center)
                .padding()
            Spacer()
        }
        .padding()
        .navigationTitle("Hakkında")
    }
}
