//  SurveyDetailView\.swift
//  Anket\_App
//
//  Created by zehra özer on 18.05.2025.
//

import SwiftUI
import AVFoundation

struct SurveyDetailView: View {
@StateObject var viewModel: SurveyDetailViewModel
    @State private var signaturePoints: [CGPoint] = []

    func renderSignature(from points: [CGPoint], size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            context.cgContext.setStrokeColor(UIColor.black.cgColor)
            context.cgContext.setLineWidth(2)
            
            var previousPoint: CGPoint? = nil
            for point in points {
                if point == .zero {
                    previousPoint = nil
                } else {
                    if let prev = previousPoint {
                        context.cgContext.move(to: prev)
                        context.cgContext.addLine(to: point)
                    }
                    previousPoint = point
                }
            }
            context.cgContext.strokePath()
        }
    }
    
    func uploadSignature(image: UIImage) {
        guard let imageData = image.pngData() else { return }
        let base64 = imageData.base64EncodedString()
        let fileName = UUID().uuidString
        let userId = UserDefaults.standard.integer(forKey: "userId")

        let json: [String: Any] = [
            "signatureBase64": base64,
            "fileName": fileName,
            "userId": userId
        ]

        guard let url = URL(string: "https://mobilprogramlama.ardglobal.com.tr/Foto_ses_kaydi_imza_swift/upload_signature.php") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: json)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("İmza gönderme hatası: \(error.localizedDescription)")
                return
            }
            if let data = data,
               let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let message = result["message"] as? String {
                print("✅ \(message)")
            } else {
                print("Sunucu cevabı okunamadı.")
            }
        }.resume()
    }

var body: some View {
    ScrollView {
        VStack(alignment: .leading, spacing: 20) {
            Text(viewModel.survey.title)
                .font(.largeTitle)
                .bold()
            
            Text(viewModel.survey.description)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            ForEach(viewModel.survey.questions) { question in
                VStack(alignment: .leading, spacing: 8) {
                    Text(question.questionText)
                        .font(.headline)
                    
                    switch question.answerType {
                    case .multipleChoice:
                        if let options = question.options {
                            MultipleChoiceView(question: question, options: options)
                                .environmentObject(viewModel)
                        }
                        
                    case .text:
                        TextAnswerView(question: question)
                            .environmentObject(viewModel)
                        
                    case .audio:
                        AudioAnswerView(question: question)
                            .environmentObject(viewModel)
                    }
                }
                .padding(.vertical)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text("İmzanız:")
                    .font(.headline)
                
                SignatureView(points: $signaturePoints)
                    .frame(height: 200)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                
                Button("İmzayı Temizle") {
                    signaturePoints.removeAll()
                }
                .foregroundColor(.red)
            }
            .padding(.top)
            
            
            Button(action: {
                              let image = renderSignature(from: signaturePoints, size: CGSize(width: 300, height: 200))
                              uploadSignature(image: image)
                              viewModel.submitSurvey()
                              print("submitSurvey tetiklendi")
                          }) {
                              Text("Anketi Gönder")
                                  .bold()
                                  .frame(maxWidth: .infinity)
                                  .padding()
                                  .background(Color.blue)
                                  .foregroundColor(.white)
                                  .cornerRadius(8)
                          }
                          .padding(.top)
                      }
                      .padding()
                  }
                  .navigationTitle("Anket Detayı")
                  .navigationBarTitleDisplayMode(.inline)
              }
          }

struct MultipleChoiceView: View {
var question: Question
var options: [String]
@EnvironmentObject var viewModel: SurveyDetailViewModel

var body: some View {
    VStack(alignment: .leading) {
        ForEach(options, id: \.self) { option in
            HStack {
                let isSelected = viewModel.answers[question.id]?.answerText == option
                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
                Text(option)
                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture {
                viewModel.setAnswer(for: question.id, text: option)
            }
            .padding(.vertical, 4)
        }
    }
}


}

struct TextAnswerView: View {
var question: Question
@EnvironmentObject var viewModel: SurveyDetailViewModel


var body: some View {
    TextEditor(text: Binding(
        get: {
            viewModel.answers[question.id]?.answerText ?? ""
        },
        set: { newValue in
            viewModel.setAnswer(for: question.id, text: newValue)
        }
    ))
    .frame(height: 100)
    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.5)))
}


}
