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
                    userId: 1,
                    surveyTitle: "Günlük Alışkanlıklar Anketi",
                    surveyDescription: "Kullanıcıların günlük alışkanlıklarını analiz etmek için",
                    answers: [
                        AnswerPayload(
                            questionId: UUID().uuidString,
                            answerText: "7",
                            audioUrl: nil
                        ),
                        AnswerPayload(
                            questionId: UUID().uuidString,
                            answerText: "Çay",
                            audioUrl: nil
                        ),
                        AnswerPayload(
                            questionId: UUID().uuidString,
                            answerText: nil,
                            audioUrl: "https://sunucum.com/audios/sesdosyasi1.m4a"
                        )
                    ]
                )
                viewModel.submitSurvey(survey: exampleSurvey)
            }
        }
        .padding()
    }
}
