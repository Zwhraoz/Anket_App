import Foundation

// Data modelleri
struct Survey: Identifiable, Codable {
    var id = UUID()
    var title: String
    var description: String
    var questions: [Question]
}

struct Question: Identifiable, Codable {
    var id = UUID()
    var questionText: String
    var answerType: AnswerType
    var options: [String]?
}

enum AnswerType: String, Codable {
    case multipleChoice
    case text
    case audio
}

struct Answer: Codable {
    var questionId: UUID
    var answerText: String?
    var audioURL: String?
}

struct SurveySubmission: Codable {
    let user_id: Int
    let survey_title: String
    let survey_description: String?
    let answers: [AnswerPayload]
}

struct AnswerPayload: Codable {
    let question_id: String
    let answer_text: String?
    let audio_url: String?
}

// Gönderme fonksiyonu
func sendSurveyAnswers(userId: Int, survey: Survey, answers: [Answer]) {
    var answerPayloads: [AnswerPayload] = []

    for question in survey.questions {
        guard let answer = answers.first(where: { $0.questionId == question.id }) else {
            continue
        }

        let payload = AnswerPayload(
            question_id: question.id.uuidString,
            answer_text: answer.answerText,
            audio_url: answer.audioURL
        )
        answerPayloads.append(payload)
    }

    let surveyPayload = SurveySubmission(
        user_id: userId,
        survey_title: survey.title,
        survey_description: survey.description,
        answers: answerPayloads
    )

    sendSurveyAnswerToServer(payload: surveyPayload)
}

func sendSurveyAnswerToServer(payload: SurveySubmission) {
    guard let url = URL(string: "https://mobilprogramlama.ardglobal.com.tr/Anket_Uygulamasi/save_survey_response.php") else {
        print("Geçersiz URL")
        return
    }
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    do {
        let data = try JSONEncoder().encode(payload)

        // Konsola gönderilen JSON'u yazdır
        if let jsonString = String(data: data, encoding: .utf8) {
            print("Gönderilen JSON: \(jsonString)")
        }

        request.httpBody = data
    } catch {
        print("Payload encode hatası: \(error.localizedDescription)")
        return
    }

    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Sunucuya gönderme hatası: \(error.localizedDescription)")
            return
        }

        if let data = data, let responseStr = String(data: data, encoding: .utf8) {
            print("Sunucu cevabı: \(responseStr)")
        }
    }.resume()
}
