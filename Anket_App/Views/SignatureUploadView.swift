import SwiftUI

struct SignatureUploadView: View {
    @State private var showSignaturePad = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    @State private var signatureImage: UIImage?
    
    var body: some View {
        VStack(spacing: 20) {
            if isLoading {
                ProgressView("İmza yükleniyor...")
            }
            
            if let image = signatureImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 3)
                    .padding()
            }
            
            Button(action: {
                showSignaturePad = true
            }) {
                HStack {
                    Image(systemName: "pencil")
                    Text(signatureImage == nil ? "İmza At" : "İmzayı Değiştir")
                }
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(10)
            }
            .padding(.horizontal)
            
            if let _ = signatureImage {
                Button(action: uploadSignature) {
                    Text("İmzayı Yükle")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .disabled(isLoading)
            }
        }
        .navigationTitle("İmza Yükleme")
        .sheet(isPresented: $showSignaturePad) {
            SignatureView { image in
                self.signatureImage = image
            }
        }
        .alert("Bilgi", isPresented: $showAlert) {
            Button("Tamam", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func uploadSignature() {
        guard let image = signatureImage else { return }
        
        // UserDefaults'tan userId'yi al
        guard let userId = UserDefaults.standard.object(forKey: "userId") as? Int else {
            alertMessage = "Kullanıcı bilgisi bulunamadı"
            showAlert = true
            return
        }
        
        isLoading = true
        
        AuthService.shared.uploadSignature(userId: userId, signatureImage: image) { success, message in
            DispatchQueue.main.async {
                isLoading = false
                alertMessage = message
                showAlert = true
                
                if success {
                    // İmza başarıyla yüklendi, gerekirse ek işlemler yapılabilir
                }
            }
        }
    }
} 