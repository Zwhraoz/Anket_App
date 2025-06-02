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
        self.isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        if let userId = UserDefaults.standard.object(forKey: "userId") {
            print("Init - Found userId in UserDefaults:", userId, "Type:", type(of: userId))
        } else {
            print("Init - No userId found in UserDefaults")
        }
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
        print("Login attempt with username:", username)
        let user = User(mail: username, password: password)
        AuthService.shared.login(user: user) { success, message, userId in
            DispatchQueue.main.async {
                self.message = message
                self.isLoggedIn = success
                
                if success {
                    print("Login başarılı")
                    if let id = userId {
                        print("Received userId from server:", id, "Type:", type(of: id))
                        UserDefaults.standard.set(id, forKey: "userId")
                        
                        if let savedId = UserDefaults.standard.object(forKey: "userId") {
                            print("Successfully saved userId:", savedId, "Type:", type(of: savedId))
                        } else {
                            print("Failed to save userId to UserDefaults")
                        }
                    } else {
                        print("login sonucu gelen userId nil")
                    }
                } else {
                    print("Login başarısız: \(message)")
                }
                
                print("Current UserDefaults contents:", UserDefaults.standard.dictionaryRepresentation())
            }
        }
    }

    func logout() {
        isLoggedIn = false
        UserDefaults.standard.removeObject(forKey: "userId")
        clearFields()
    }

    private func clearFields() {
        username = ""
        password = ""
    }
}
