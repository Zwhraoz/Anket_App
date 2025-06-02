import SwiftUI
import Combine
import Foundation
import AVFoundation

// VIEW MODELS
class SurveyDetailViewModel: ObservableObject {
    @Published var survey: Survey
    @Published var answers: [UUID: AnswerPayload] = [:] // questionId -> AnswerPayload
    
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var successMessage: String? = nil

    init(survey: Survey) {
        self.survey = survey
        for question in survey.questions {
            answers[question.id] = AnswerPayload(questionId: question.id.uuidString, answerText: nil, audioUrl: nil)
        }
    }
    
    func setAnswer(for questionId: UUID, text: String?) {
        if var answer = answers[questionId] {
            answer.answerText = text
            answers[questionId] = answer
        }
    }

    func saveAudioAnswer(for questionId: UUID, base64Audio: String, fileName: String) {
        if var answer = answers[questionId] {
            answer.audioUrl = base64Audio
            answers[questionId] = answer

            // Upload işlemi
            uploadAudioAnswerToServer(
                questionId: questionId,
                base64Audio: base64Audio,
                answerText: answer.answerText ?? "",
                fileName: fileName
            ) { success in
                DispatchQueue.main.async {
                    if success {
                        self.successMessage = "Ses kaydı başarıyla yüklendi."
                    } else {
                        self.errorMessage = "Ses kaydı yüklenemedi."
                    }
                }
            }
        }
    }
    func uploadAudioAnswerToServer(
        questionId: UUID,
        base64Audio: String,
        answerText: String,
        fileName: String,
        completion: @escaping (Bool) -> Void
    ) {
        guard let url = URL(string: "https://mobilprogramlama.ardglobal.com.tr/Foto_ses_kaydi_imza_swift/upload_audio.php") else {
            completion(false)
            return
        }

        guard let storedUserId = UserDefaults.standard.object(forKey: "userId") else {
            DispatchQueue.main.async {
                self.errorMessage = "Kullanıcı ID bulunamadı"
            }
            completion(false)
            return
        }

        let userId = Int("\(storedUserId)") ?? -1

        let json: [String: Any] = [
            "userId": userId,
            "fileName": fileName,
            "audioBase64": base64Audio
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: json)
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "JSON oluşturulamadı: \(error.localizedDescription)"
            }
            completion(false)
            return
        }

        let session = URLSession(configuration: .default)
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Upload error: \(error.localizedDescription)")
                completion(false)
                return
            }
            guard let data = data else {
                print("Sunucudan veri gelmedi")
                completion(false)
                return
            }

            if let responseString = String(data: data, encoding: .utf8) {
                print("Upload response: \(responseString)")
            }

            completion(true)
        }.resume()
    }
    func submitSurvey() {
        guard let url = URL(string: "https://mobilprogramlama.ardglobal.com.tr/Foto_ses_kaydi_imza_swift/save_survey_response.php") else {
            DispatchQueue.main.async {
                self.errorMessage = "Geçersiz URL"
            }
            return
        }
           
        guard let storedUserId = UserDefaults.standard.object(forKey: "userId") else {
            DispatchQueue.main.async {
                self.errorMessage = "Kullanıcı ID bulunamadı"
            }
            return
        }

        var userId: Int?
        if let id = storedUserId as? Int {
            userId = id
        } else if let idString = storedUserId as? String, let idFromString = Int(idString) {
            userId = idFromString
        } else {
            DispatchQueue.main.async {
                self.errorMessage = "Geçersiz kullanıcı ID formatı"
            }
            return
        }
        
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        let answersArray = answers.values.map { $0 }
        
        let submission = SurveySubmission(
            userId: userId!,
            surveyTitle: survey.title,
            surveyDescription: survey.description,
            answers: answersArray
        )

        guard let jsonData = try? JSONEncoder().encode(submission) else {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = "JSON encode hatası"
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        let session = URLSession(configuration: .default, delegate: URLSessionPinningDelegate(), delegateQueue: nil)

        session.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = "Gönderim hatası: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    self?.errorMessage = "Sunucudan veri gelmedi"
                    return
                }
                
                if let responseString = String(data: data, encoding: .utf8) {
                    // Sunucu cevabını işleme
                    if let jsonData = responseString.data(using: .utf8) {
                        do {
                            if let result = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
                               let message = result["message"] as? String {
                                self?.successMessage = message
                            } else {
                                self?.successMessage = responseString
                            }
                        } catch {
                            self?.successMessage = responseString
                        }
                    } else {
                        self?.errorMessage = "Sunucu cevabı okunamadı"
                    }
                } else {
                    self?.errorMessage = "Sunucu cevabı okunamadı"
                }
            }
        }.resume()
    }
}

// Sertifika doğrulamasını pas geçmek için delegate sınıfı
class URLSessionPinningDelegate: NSObject, URLSessionDelegate {
    func urlSession(_ session: URLSession,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if let serverTrust = challenge.protectionSpace.serverTrust {
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}
