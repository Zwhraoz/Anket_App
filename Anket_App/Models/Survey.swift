import Foundation

// Data modelleri

struct Survey: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let questions: [Question]
    
    // Eğer id dışarıdan verilmezse otomatik UUID atanabilir
    init(id: UUID = UUID(), title: String, description: String, questions: [Question]) {
        self.id = id
        self.title = title
        self.description = description
        self.questions = questions
    }
}

struct Question: Identifiable, Codable {
    let id: UUID
    let questionText: String
    let answerType: AnswerType
    let options: [String]?
    
    init(id: UUID = UUID(), questionText: String, answerType: AnswerType, options: [String]? = nil) {
        self.id = id
        self.questionText = questionText
        self.answerType = answerType
        self.options = options
    }
    
    enum AnswerType: String, Codable {
        case multipleChoice
        case text
        case audio
    }
}

struct AnswerPayload: Codable {
    let questionId: String
    var answerText: String?
    var audioUrl: String?

    enum CodingKeys: String, CodingKey {
        case questionId = "question_id"
        case answerText = "answer_text"
        case audioUrl = "audio_url"
    }
}
// Yeni: Answer struct tanımı
struct Answer {
    let questionId: UUID
    var answerText: String?
    var audioURL: String?
}

struct SurveySubmission: Codable {
    var userId: Int
    var surveyTitle: String
    var surveyDescription: String?  // <-- opsiyonel olmalı
    var answers: [AnswerPayload]



    enum CodingKeys: String, CodingKey {
        case userId = "userId"
        case surveyTitle = "surveyTitle"
        case surveyDescription = "surveyDescription"
        case answers = "answers"
    }
}


// Gönderme fonksiyonu
func sendSurveyAnswers(userId: Int, survey: Survey, answers: [Answer]) {
    var answerPayloads: [AnswerPayload] = []

    for question in survey.questions {
        guard let answer = answers.first(where: { $0.questionId == question.id }) else {
            continue
        }

        let payload = AnswerPayload(
            questionId: question.id.uuidString,
            answerText: answer.answerText,
            audioUrl: answer.audioURL
        )
        answerPayloads.append(payload)
    }

    let surveyPayload = SurveySubmission(
        userId: userId,
        surveyTitle: survey.title,
        surveyDescription: survey.description,
        answers: answerPayloads
    )

    sendSurveyAnswerToServer(payload: surveyPayload)
}

func sendSurveyAnswerToServer(payload: SurveySubmission) {
    guard let url = URL(string: "https://mobilprogramlama.ardglobal.com.tr/Foto_ses_kaydi_imza_swift/save_survey_response.php") else {
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
