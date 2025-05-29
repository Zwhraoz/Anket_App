import SwiftUI

struct SurveyView: View {
    @StateObject private var viewModel = SurveyViewModel()

    var body: some View {
        VStack(spacing: 20) {
            if viewModel.isLoading {
                ProgressView("Gönderiliyor...")
            }

            if let error = viewModel.errorMessage {
                Text("Hata: \(error)").foregroundColor(.red)
            }

            if let success = viewModel.successMessage {
                Text("Başarılı: \(success)").foregroundColor(.green)
            }

            Button("Anketi Gönder") {
                let exampleSurvey = SurveySubmission(
                    user_id: 1,
                    survey_title: "Günlük Alışkanlıklar Anketi",
                    survey_description: "Kullanıcıların günlük alışkanlıklarını analiz etmek için",
                    answers: [
                        AnswerPayload(
                            question_id: UUID().uuidString,
                            answer_text: "7",
                            audio_url: nil
                        ),
                        AnswerPayload(
                            question_id: UUID().uuidString,
                            answer_text: "Çay",
                            audio_url: nil
                        ),
                        AnswerPayload(
                            question_id: UUID().uuidString,
                            answer_text: nil,
                            audio_url: "https://sunucum.com/audios/sesdosyasi1.m4a"
                        )
                    ]
                )
                viewModel.submitSurvey(survey: exampleSurvey)
            }
        }
        .padding()
    }
}
