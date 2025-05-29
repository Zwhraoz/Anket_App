import Foundation
import Combine

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



class SurveyDetailViewModel: ObservableObject {
    @Published var survey: Survey
    @Published var answers: [UUID: Answer] = [:] // questionId -> answer

    init(survey: Survey) {
        self.survey = survey
        // Başlangıçta boş cevaplar oluşturuyoruz
        for question in survey.questions {
            answers[question.id] = Answer(questionId: question.id, answerText: nil, audioURL: nil)
        }
    }

    func setAnswer(for questionId: UUID, text: String?) {
        answers[questionId]?.answerText = text
    }

    func saveAudioAnswer(for questionId: UUID, audioURL: String) {
        answers[questionId]?.audioURL = audioURL
    }

    func submitSurvey() {
        guard let  url = URL(string: "https://mobilprogramlama.ardglobal.com.tr/Anket_Uygulamasi/save_survey_response.php")
 else {
            print("Geçersiz URL")
            return
        }

     

        // TODO: Gerçek user ID ile değiştir
        let userId = 123

        let answersArray = answers.map { (key, value) in
            AnswerPayload(
                question_id: key.uuidString,
                answer_text: value.answerText,
                audio_url: value.audioURL
            )
        }

        let submission = SurveySubmission(
            user_id: userId,
            survey_title: survey.title,
            survey_description: survey.description,
            answers: answersArray
        )

        guard let jsonData = try? JSONEncoder().encode(submission) else {
            print("JSON encode edilemedi")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        let session = URLSession(configuration: .default, delegate: URLSessionPinningDelegate(), delegateQueue: nil)

        session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Gönderim hatası: \(error.localizedDescription)")
                    return
                }

                guard let data = data else {
                    print("Sunucudan veri gelmedi")
                    return
                }

                if let responseStr = String(data: data, encoding: .utf8) {
                    print("Sunucu cevabı: \(responseStr)")
                } else {
                    print("Sunucu cevabı okunamadı")
                }
            }
        }.resume()
    }
}
