//
//  SurveyViewModel.swift
//  Anket_App
//
//  Created by zehra özer on 29.05.2025.
//

import Foundation



class SurveyViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var successMessage: String? = nil

    func submitSurvey(survey: SurveySubmission) {
        isLoading = true
        errorMessage = nil
        successMessage = nil

        guard let url = URL(string: "https://mobilprogramlama.ardglobal.com.tr/Anket_Uygulamasi/save_survey_response.php") else {
            self.isLoading = false
            self.errorMessage = "URL geçersiz"
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let jsonData = try JSONEncoder().encode(survey)
            request.httpBody = jsonData
        } catch {
            self.isLoading = false
            self.errorMessage = "JSON encode hatası: \(error.localizedDescription)"
            return
        }

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false

                if let error = error {
                    self?.errorMessage = "İstek hatası: \(error.localizedDescription)"
                    return
                }

                guard let data = data else {
                    self?.errorMessage = "Sunucudan veri alınamadı"
                    return
                }

                do {
                    if let result = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let message = result["message"] as? String {
                        self?.successMessage = message
                    } else {
                        self?.errorMessage = "Sunucu cevabı çözülemedi"
                    }
                } catch {
                    self?.errorMessage = "JSON parse hatası: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}
