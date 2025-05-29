import Foundation

class AuthViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var message: String = ""
    
    @Published var isLoggedIn: Bool {
        didSet {
            UserDefaults.standard.set(isLoggedIn, forKey: "isLoggedIn")
        }
    }

    init() {
        // Uygulama ilk açıldığında giriş yapıldı mı kontrol et
        self.isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
    }

    func register() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if self.username.isEmpty || self.password.isEmpty {
                self.message = "Kullanıcı adı ve şifre boş olamaz."
            } else {
                self.message = "Kayıt başarılı (mock)."
                self.clearFields()
            }
        }
    }

    func login() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if self.username == "testuser" && self.password == "123456" {
                self.message = ""
                self.isLoggedIn = true
            } else {
                self.message = "Kullanıcı adı veya şifre yanlış."
                self.isLoggedIn = false
            }
        }
    }

    func logout() {
        isLoggedIn = false
        clearFields()
    }

    private func clearFields() {
        username = ""
        password = ""
    }
}
