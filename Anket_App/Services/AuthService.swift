import Foundation

struct ServerResponse: Codable {
    var success: Bool
    var message: String
}

class AuthService: NSObject, URLSessionDelegate {
    static let shared = AuthService()

    private let baseURL = "https://mobilprogramlama.ardglobal.com.tr/Anket_Uygulamasi"

    // URLSession nesnesini delegate ile oluşturuyoruz:
    lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()

    func register(user: User, completion: @escaping (Bool, String) -> Void) {
        guard let url = URL(string: "\(baseURL)/register.php") else {
            completion(false, "Geçersiz URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(user)

        session.dataTask(with: request) { data, response, error in
            if let data = data {
                if let result = try? JSONDecoder().decode(ServerResponse.self, from: data) {
                    completion(result.success, result.message)
                } else {
                    completion(false, "Sunucu cevabı çözülemedi")
                }
            } else {
                completion(false, error?.localizedDescription ?? "Bilinmeyen hata")
            }
        }.resume()
    }

    func login(user: User, completion: @escaping (Bool, String) -> Void) {
        guard let url = URL(string: "\(baseURL)/login.php") else {
            completion(false, "Geçersiz URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(user)

        session.dataTask(with: request) { data, response, error in
            if let data = data {
                if let result = try? JSONDecoder().decode(ServerResponse.self, from: data) {
                    completion(result.success, result.message)
                } else {
                    completion(false, "Sunucu cevabı çözülemedi")
                }
            } else {
                completion(false, error?.localizedDescription ?? "Bilinmeyen hata")
            }
        }.resume()
    }

    // MARK: - URLSessionDelegate ile Sertifika Doğrulama

    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {

        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
           let serverTrust = challenge.protectionSpace.serverTrust {

            // Burada sertifikayı manuel kabul ediyoruz (yalnızca test için)
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}
