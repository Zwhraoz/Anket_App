import Foundation

struct SurveyAnswer: Codable {
    var user_id: String
    var survey_title: String
    var survey_description: String
    var question_text: String
    var answer_type: String // "multipleChoice", "text", "audio"
    var options: [String]? // multiple choice seçenekleri
    var answer_text: String?
    var audio_url: String?
}

class SurveyService {
    static let shared = SurveyService()
    
    private let baseURL = "https://mobilprogramlama.ardglobal.com.tr/Anket_Uygulamasi"
    
    func saveSurveyAnswer(answer: SurveyAnswer, completion: @escaping (Bool, String) -> Void) {
        guard let url = URL(string: "\(baseURL)/save_survey.php") else {
            completion(false, "Geçersiz URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(answer)
            request.httpBody = jsonData
        } catch {
            completion(false, "JSON encode hatası")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
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
}
