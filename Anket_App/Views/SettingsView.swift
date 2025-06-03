import SwiftUI
import MessageUI

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
            ScrollView {
                VStack(spacing: 30) {
                    profileSection
                    
                    Divider()
                    
                    appearanceSection
                    
                    Divider()
                    
                    notificationsSection
                    
                    Divider()
                    
                    supportSection
                    
                    Divider()
                    
                    dataManagementSection
                    
                    Divider()
                    
                    logoutSection
                    
                    versionSection
                }
                .padding()
            }
            .navigationTitle("Ayarlar")
            .sheet(isPresented: $isEditingProfile) { profileEditSheet }
            .alert("Tüm veriler silinsin mi?", isPresented: $showResetAlert) {
                Button("Evet", role: .destructive) { resetAppData() }
                Button("İptal", role: .cancel) { }
            } message: {
                Text("Bu işlem geri alınamaz!")
            }
            .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
    
    // MARK: - Sections
    
    private var profileSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "Profil")
            
            HStack(spacing: 15) {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 70, height: 70)
                    .foregroundColor(.blue)
                    .background(
                        Circle()
                            .fill(Color.blue.opacity(0.15))
                            .frame(width: 80, height: 80)
                    )
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(userName)
                        .font(.title3.bold())
                    Text(userEmail)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Button {
                    tempName = userName
                    tempEmail = userEmail
                    isEditingProfile = true
                } label: {
                    Image(systemName: "pencil.circle.fill")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .foregroundColor(.blue)
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
    }
    
    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "Görünüm")
            
            Toggle(isOn: $isDarkMode) {
                Label("Koyu Mod", systemImage: "moon.fill")
                    .foregroundColor(.blue)
            }
            .toggleStyle(SwitchToggleStyle(tint: .blue))
            
            Picker(selection: $appLanguage, label:
                    Label("Uygulama Dili", systemImage: "globe")
                        .foregroundColor(.blue)
            ) {
                ForEach(languages, id: \.self) { lang in
                    Text(lang).tag(lang)
                }
            }
            .pickerStyle(MenuPickerStyle())
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 3)
    }
    
    private var notificationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "Bildirimler")
            
            Toggle(isOn: .constant(true)) {
                Label("Anket Hatırlatmaları", systemImage: "bell.fill")
                    .foregroundColor(.orange)
            }
            .toggleStyle(SwitchToggleStyle(tint: .orange))
            
            Toggle(isOn: .constant(false)) {
                Label("Yeni Özellikler", systemImage: "sparkles")
                    .foregroundColor(.green)
            }
            .toggleStyle(SwitchToggleStyle(tint: .green))
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 3)
    }
    
    private var supportSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "Yardım ve Destek")
            
            Button {
                showMailComposer = true
            } label: {
                HStack {
                    Image(systemName: "envelope.fill")
                        .foregroundColor(.purple)
                    Text("Bize Ulaşın")
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 8)
            }
            .buttonStyle(PlainButtonStyle())
            
            NavigationLink(destination: AboutView()) {
                HStack {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.blue)
                    Text("Hakkında")
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 8)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 3)
    }
    
    private var dataManagementSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "Veri Yönetimi")
            
            Button(role: .destructive) {
                showResetAlert = true
            } label: {
                HStack {
                    Image(systemName: "trash.fill")
                        .foregroundColor(.red)
                    Text("Tüm Verileri Sıfırla")
                        .foregroundColor(.red)
                    Spacer()
                }
                .padding(.vertical, 8)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 3)
    }
    
    private var logoutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(role: .destructive) {
                signOut()
            } label: {
                HStack {
                    Image(systemName: "arrow.backward.square.fill")
                        .foregroundColor(.red)
                    Text("Çıkış Yap")
                        .foregroundColor(.red)
                    Spacer()
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    private var versionSection: some View {
        HStack {
            Text("Sürüm")
                .foregroundColor(.secondary)
            Spacer()
            Text("1.0.0")
                .foregroundColor(.secondary)
        }
        .padding(.top, 20)
        .font(.footnote)
    }
    
    // MARK: - Helpers
    
    private func sectionHeader(title: String) -> some View {
        Text(title.uppercased())
            .font(.caption)
            .fontWeight(.bold)
            .foregroundColor(.gray)
            .padding(.bottom, 4)
    }
    
    private var profileEditSheet: some View {
        NavigationView {
            Form {
                Section(header: Text("Ad Soyad")) {
                    TextField("Ad Soyad", text: $tempName)
                        .autocapitalization(.words)
                }
                Section(header: Text("E-posta")) {
                    TextField("E-posta", text: $tempEmail)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
            }
            .navigationTitle("Profili Düzenle")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") {
                        isEditingProfile = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") {
                        userName = tempName
                        userEmail = tempEmail
                        isEditingProfile = false
                    }
                }
            }
        }
    }
    
    private func resetAppData() {
        userName = "Kullanıcı Adı"
        userEmail = "kullanici@example.com"
        appLanguage = "Türkçe"
        isDarkMode = false
    }
    
    private func signOut() {
        userName = "Kullanıcı Adı"
        userEmail = "kullanici@example.com"
        appLanguage = "Türkçe"
        isDarkMode = false
        
        authVM.isLoggedIn = false
    }
}

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
