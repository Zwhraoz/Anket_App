import Foundation

struct ServerResponse: Codable {
    var success: Bool
    var message: String
    var userId: Int?    // Opsiyonel çünkü bazı durumlarda dönmeyebilir (örneğin kayıt başarısızsa)
}

class AuthService: NSObject, URLSessionDelegate {
    static let shared = AuthService()

    private let baseURL = "https://mobilprogramlama.ardglobal.com.tr/Foto_ses_kaydi_imza_swift"

    lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()

    // Kullanıcı kaydı
    func register(user: User, completion: @escaping (Bool, String, Int?) -> Void) {
        guard let url = URL(string: "\(baseURL)/register.php") else {
            completion(false, "Geçersiz URL", nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(user)

        session.dataTask(with: request) { data, response, error in
            if let data = data {
                print("Kayıt cevabı JSON:", String(data: data, encoding: .utf8) ?? "boş")
                if let result = try? JSONDecoder().decode(ServerResponse.self, from: data) {
                    completion(result.success, result.message, result.userId)
                } else {
                    completion(false, "Sunucu cevabı çözülemedi", nil)
                }
            } else {
                completion(false, error?.localizedDescription ?? "Bilinmeyen hata", nil)
            }
        }.resume()
    }

    // Kullanıcı girişi
    func login(user: User, completion: @escaping (Bool, String, Int?) -> Void) {
        guard let url = URL(string: "\(baseURL)/login.php") else {
            print("Login URL oluşturulamadı")
            completion(false, "Geçersiz URL", nil)
            return
        }

        print("Login isteği gönderiliyor - URL:", url.absoluteString)
        print("Login isteği gönderiliyor - User:", user)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(user)
            request.httpBody = jsonData
            print("Gönderilen JSON:", String(data: jsonData, encoding: .utf8) ?? "boş")
        } catch {
            print("JSON encoding hatası:", error)
            completion(false, "JSON encoding hatası", nil)
            return
        }

        session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error:", error)
                completion(false, error.localizedDescription, nil)
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code:", httpResponse.statusCode)
            }

            if let data = data {
                print("Login cevabı raw data length:", data.count)
                print("Login cevabı JSON:", String(data: data, encoding: .utf8) ?? "boş")
                
                do {
                    let result = try JSONDecoder().decode(ServerResponse.self, from: data)
                    print("Decoded response - success:", result.success)
                    print("Decoded response - message:", result.message)
                    print("Decoded response - userId:", result.userId as Any)
                    completion(result.success, result.message, result.userId)
                } catch {
                    print("JSON decode hatası:", error)
                    if let str = String(data: data, encoding: .utf8) {
                        print("Raw response:", str)
                    }
                    completion(false, "Sunucu cevabı çözülemedi: \(error.localizedDescription)", nil)
                }
            } else {
                print("No data received from server")
                completion(false, "Sunucudan veri alınamadı", nil)
            }
        }.resume()
    }

    // MARK: - URLSessionDelegate: Sertifika doğrulama (test amaçlı bypass)
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
           let serverTrust = challenge.protectionSpace.serverTrust {
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}
