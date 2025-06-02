import Foundation

class SurveyListViewModel: ObservableObject {
    @Published var surveys: [Survey] = []
    @Published var searchText: String = ""
    
    var filteredSurveys: [Survey] {
        if searchText.isEmpty {
            return surveys
        } else {
            return surveys.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    func loadSurveys() {
        surveys = [
            Survey(
                title: "Müşteri Memnuniyeti Anketi",
                description: "Ürün ve hizmetlerimiz hakkındaki görüşleriniz.",
                questions: [
                    Question(questionText: "Ürün kalitesinden memnun musunuz?", answerType: .multipleChoice, options: ["Evet", "Hayır", "Kısmen"]),
                    Question(questionText: "Teslimat süresi nasıldı?", answerType: .multipleChoice, options: ["Hızlı", "Normal", "Geç kaldı"]),
                    Question(questionText: "Tekrar alışveriş yapar mısınız?", answerType: .multipleChoice, options: ["Evet", "Hayır"])
                ]
            ),
            Survey(
                title: "Örnek Anket",
                description: "Anket açıklaması",
                questions: [
                    Question(questionText: "Favori mevsimin?", answerType: .multipleChoice, options: ["Yaz", "Kış", "İlkbahar", "Sonbahar"]),
                    Question(questionText: "Bize bir şeyler yazınız.", answerType: .text),
                    Question(questionText: "Lütfen ses kaydı yapınız.", answerType: .audio)
                ]
            ),
            Survey(
                title: "Çalışan Memnuniyeti Anketi",
                description: "İş yerindeki memnuniyetiniz hakkında.",
                questions: [
                    Question(questionText: "İş yerinde kendinizi değerli hissediyor musunuz?", answerType: .multipleChoice, options: ["Evet", "Hayır", "Bazen"]),
                    Question(questionText: "Çalışma ortamınız konforlu mu?", answerType: .multipleChoice, options: ["Evet", "Hayır"]),
                    Question(questionText: "İş arkadaşlarınızla ilişkiniz nasıl?", answerType: .multipleChoice, options: ["İyi", "Orta", "Kötü"])
                ]
            ),
            
            // Diğer anketler için örnekler
            Survey(
                title: "Teknoloji Kullanım Alışkanlıkları",
                description: "Günlük teknoloji kullanımı ve tercihleriniz.",
                questions: [
                    Question(questionText: "Günde kaç saat teknoloji kullanıyorsunuz?", answerType: .multipleChoice, options: ["1-2 saat", "3-5 saat", "5 saatten fazla"]),
                    Question(questionText: "En çok kullandığınız cihaz nedir?", answerType: .multipleChoice, options: ["Telefon", "Tablet", "Bilgisayar", "Diğer"]),
                    Question(questionText: "Teknoloji ile ilgili düşüncelerinizi yazınız.", answerType: .text)
                ]
            ),
            Survey(
                title: "Sağlık ve Spor",
                description: "Sağlık alışkanlıklarınız ve spor yapma durumunuz.",
                questions: [
                    Question(questionText: "Haftada kaç gün spor yapıyorsunuz?", answerType: .multipleChoice, options: ["Hiç yapmıyorum", "1-2 gün", "3-5 gün", "Her gün"]),
                    Question(questionText: "En sevdiğiniz spor dalı nedir?", answerType: .text),
                    Question(questionText: "Spor yaparken ses kaydı ile motivasyonunuzu anlatınız.", answerType: .audio)
                ]
            ),
            // ... diğer anketleri benzer şekilde ekleyebilirsiniz ...
            
            Survey(
                title: "Teknoloji Geleceği",
                description: "Teknolojinin geleceği hakkındaki görüşleriniz.",
                questions: [
                    Question(questionText: "Teknolojinin hayatımızdaki rolü nasıl olacak?", answerType: .text),
                    Question(questionText: "Teknoloji ile ilgili sesli düşüncelerinizi paylaşınız.", answerType: .audio)
                ]
            )
        ]
    }
}
