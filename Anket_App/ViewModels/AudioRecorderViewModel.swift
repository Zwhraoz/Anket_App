import SwiftUI
import AVFoundation

struct AudioAnswerView: View {
    var question: Question
    @EnvironmentObject var viewModel: SurveyDetailViewModel
    
    @State private var isRecording = false
    @State private var isPlaying = false
    @State private var audioURL: URL?
    
    @State private var audioRecorder: AVAudioRecorder?
    @State private var audioPlayer: AVAudioPlayer?
    
    @State private var recordedFileName: String? = nil // Dosya adı saklanacak
    
    var body: some View {
        VStack(spacing: 15) {
            Button(action: {
                if isRecording {
                    stopRecording()
                } else {
                    requestMicrophonePermissionAndStart()
                }
            }) {
                HStack {
                    Image(systemName: isRecording ? "stop.circle.fill" : "mic.circle.fill")
                        .font(.largeTitle)
                    Text(isRecording ? "Kaydı Durdur" : "Ses Kaydı Başlat")
                }
            }
            .disabled(isPlaying)
            
            if audioURL != nil {
                Button(action: {
                    if isPlaying {
                        stopPlaying()
                    } else {
                        startPlaying()
                    }
                }) {
                    HStack {
                        Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                            .font(.title)
                        Text(isPlaying ? "Durdur" : "Dinle")
                    }
                }
                .disabled(isRecording)
            }
            
            if let url = audioURL {
                Text("Kayıt tamamlandı: \(url.lastPathComponent)")
                    .font(.caption)
                    .foregroundColor(.green)
            }
        }
        .padding(.vertical)
        .onDisappear {
            if isRecording { stopRecording() }
            if isPlaying { stopPlaying() }
        }
    }
    
    func requestMicrophonePermissionAndStart() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            startRecording()
        case .denied:
            print("Mikrofon izni reddedildi.")
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { allowed in
                DispatchQueue.main.async {
                    if allowed {
                        startRecording()
                    } else {
                        print("Mikrofon izni reddedildi.")
                    }
                }
            }
        @unknown default:
            print("Bilinmeyen mikrofon izni durumu.")
        }
    }
    
    func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try audioSession.setActive(true)
            
            let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let filename = UUID().uuidString
            let fileURL = documents.appendingPathComponent(filename + ".m4a")
            
            recordedFileName = filename
            
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
            audioRecorder?.record()
            
            isRecording = true
            audioURL = nil
        } catch {
            print("Kayıt başlatılamadı: \(error.localizedDescription)")
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        if let url = audioRecorder?.url, let fileName = recordedFileName {
            audioURL = url
            
            do {
                let audioData = try Data(contentsOf: url)
                let base64String = audioData.base64EncodedString()
                
                // PHP'ye base64 ve dosya adını gönder
                if let fileName = recordedFileName {
                    viewModel.saveAudioAnswer(for: question.id, base64Audio: base64String, fileName: fileName)
                }            } catch {
                print("Ses dosyası okunamadı: \(error.localizedDescription)")
            }
        }
        isRecording = false
        audioRecorder = nil
    }
    
    func startPlaying() {
        guard let url = audioURL else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
            isPlaying = true
            audioPlayer?.delegate = AudioPlayerDelegate { finished in
                DispatchQueue.main.async {
                    isPlaying = !finished
                }
            }
        } catch {
            print("Oynatma başlatılamadı: \(error.localizedDescription)")
        }
    }
    
    func stopPlaying() {
        audioPlayer?.stop()
        isPlaying = false
        audioPlayer = nil
    }
    
    class AudioPlayerDelegate: NSObject, AVAudioPlayerDelegate {
        var onFinish: (Bool) -> Void
        
        init(onFinish: @escaping (Bool) -> Void) {
            self.onFinish = onFinish
        }
        
        func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
            onFinish(flag)
        }
    }
}
