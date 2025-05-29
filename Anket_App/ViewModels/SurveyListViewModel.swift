import Foundation

class SurveyListViewModel: ObservableObject {
    @Published var surveys: [Survey] = []
    @Published var searchText = ""
    
    var filteredSurveys: [Survey] {
        if searchText.isEmpty {
            return surveys
        } else {
            return surveys.filter { $0.title.lowercased().contains(searchText.lowercased()) }
        }
    }
    func loadSurveys() {
        surveys = [
            Survey(
                title: "Müşteri Memnuniyeti Anketi",
                description: "Ürün ve hizmetlerimiz hakkındaki görüşleriniz.",
                questions: [
                    Question(
                        questionText: "Ürün kalitesinden memnun musunuz?",
                        answerType: .multipleChoice,
                        options: ["Evet", "Hayır", "Kısmen"]
                    ),
                    Question(
                        questionText: "Teslimat süresi nasıldı?",
                        answerType: .multipleChoice,
                        options: ["Hızlı", "Normal", "Geç kaldı"]
                    ),
                    Question(
                        questionText: "Tekrar alışveriş yapar mısınız?",
                        answerType: .multipleChoice,
                        options: ["Evet", "Hayır"]
                    )
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
                    Question(
                        questionText: "İş yerinde kendinizi değerli hissediyor musunuz?",
                        answerType: .multipleChoice,
                        options: ["Evet", "Hayır", "Bazen"]
                    ),
                    Question(
                        questionText: "Çalışma ortamınız konforlu mu?",
                        answerType: .multipleChoice,
                        options: ["Evet", "Hayır"]
                    ),
                    Question(
                        questionText: "İş arkadaşlarınızla ilişkiniz nasıl?",
                        answerType: .multipleChoice,
                        options: ["İyi", "Orta", "Kötü"]
                    )
                ]
            ),

            // --- 12 Yeni Anket Başlangıcı ---

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

            Survey(
                title: "Eğitim Memnuniyeti",
                description: "Aldığınız eğitim ve öğretim ile ilgili görüşler.",
                questions: [
                    Question(questionText: "Eğitim kalitesinden memnun musunuz?", answerType: .multipleChoice, options: ["Evet", "Hayır", "Kısmen"]),
                    Question(questionText: "Eğitim sürecinde neler geliştirilmelidir?", answerType: .text)
                ]
            ),

            Survey(
                title: "Çevre Bilinci",
                description: "Çevre koruma ve geri dönüşüm alışkanlıklarınız.",
                questions: [
                    Question(questionText: "Geri dönüşüm yapıyor musunuz?", answerType: .multipleChoice, options: ["Evet", "Hayır", "Bazen"]),
                    Question(questionText: "Çevre koruma için neler yapıyorsunuz?", answerType: .text),
                    Question(questionText: "Çevre ile ilgili düşüncelerinizi ses kaydı olarak bırakınız.", answerType: .audio)
                ]
            ),

            Survey(
                title: "Seyahat Alışkanlıkları",
                description: "Seyahat tercihleri ve deneyimleriniz.",
                questions: [
                    Question(questionText: "Yılda kaç kez seyahat edersiniz?", answerType: .multipleChoice, options: ["Hiç", "1-2 kere", "3-5 kere", "5+"]),
                    Question(questionText: "Favori seyahat destinasyonunuz nedir?", answerType: .text)
                ]
            ),

            Survey(
                title: "Film ve Dizi Tercihleri",
                description: "Film ve dizi izleme alışkanlıklarınız.",
                questions: [
                    Question(questionText: "En sevdiğiniz film türü nedir?", answerType: .multipleChoice, options: ["Aksiyon", "Dram", "Komedi", "Bilim Kurgu"]),
                    Question(questionText: "Son izlediğiniz filmi kısaca anlatınız.", answerType: .text)
                ]
            ),

            Survey(
                title: "Alışveriş Alışkanlıkları",
                description: "Tüketim ve alışveriş tercihlerinize dair sorular.",
                questions: [
                    Question(questionText: "Online alışveriş yapıyor musunuz?", answerType: .multipleChoice, options: ["Evet", "Hayır"]),
                    Question(questionText: "En çok hangi kategoriden alışveriş yaparsınız?", answerType: .text),
                    Question(questionText: "Alışveriş deneyiminizi ses kaydı ile paylaşınız.", answerType: .audio)
                ]
            ),

            Survey(
                title: "Sosyal Medya Kullanımı",
                description: "Sosyal medya alışkanlıklarınız hakkında.",
                questions: [
                    Question(questionText: "Günde kaç saat sosyal medya kullanıyorsunuz?", answerType: .multipleChoice, options: ["1 saatten az", "1-3 saat", "3 saatten fazla"]),
                    Question(questionText: "Favori sosyal medya platformunuz hangisi?", answerType: .text)
                ]
            ),

            Survey(
                title: "Yemek Tercihleri",
                description: "Yemek alışkanlıklarınız ve tercihlerinize dair sorular.",
                questions: [
                    Question(questionText: "En sevdiğiniz yemek türü nedir?", answerType: .multipleChoice, options: ["Türk Mutfağı", "İtalyan", "Çin", "Meksika"]),
                    Question(questionText: "Son yediğiniz yemeği tarif edin.", answerType: .text)
                ]
            ),

            Survey(
                title: "Kitap Okuma Alışkanlıkları",
                description: "Okuma tercihleri ve kitap türleri hakkında.",
                questions: [
                    Question(questionText: "Ayda kaç kitap okuyorsunuz?", answerType: .multipleChoice, options: ["Hiç", "1-2", "3-5", "5+"]),
                    Question(questionText: "Favori kitap türünüz nedir?", answerType: .text)
                ]
            ),

            Survey(
                title: "İş Tatmini",
                description: "İş yerindeki memnuniyet ve motivasyonunuz.",
                questions: [
                    Question(questionText: "İşinizden memnun musunuz?", answerType: .multipleChoice, options: ["Evet", "Hayır", "Kısmen"]),
                    Question(questionText: "İş yerinde sizi en çok motive eden şey nedir?", answerType: .text)
                ]
            ),

            Survey(
                title: "Ulaşım Tercihleri",
                description: "Günlük ulaşım alışkanlıklarınız.",
                questions: [
                    Question(questionText: "Genellikle hangi ulaşım aracını kullanırsınız?", answerType: .multipleChoice, options: ["Araç", "Toplu taşıma", "Yürüyerek", "Bisiklet"]),
                    Question(questionText: "Ulaşım sırasında yaşadığınız sorunları yazınız.", answerType: .text)
                ]
            ),

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
