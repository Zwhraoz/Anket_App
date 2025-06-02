//
//  AudioAnswerView.swift
//  Anket_App
//
//  Created by zehra özer on 18.05.2025.
//

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
    
    @State private var recordedFileName: String? = nil
    
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
    }
    
    private func requestMicrophonePermissionAndStart() {
        AVAudioSession.sharedInstance().requestRecordPermission { allowed in
            DispatchQueue.main.async {
                if allowed {
                    self.startRecording()
                }
            }
        }
    }
    
    private func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            
            let fileName = "\(UUID().uuidString).m4a"
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let audioURL = documentsPath.appendingPathComponent(fileName)
            
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            audioRecorder = try AVAudioRecorder(url: audioURL, settings: settings)
            audioRecorder?.record()
            
            isRecording = true
            recordedFileName = fileName
        } catch {
            print("Kayıt başlatılamadı: \(error.localizedDescription)")
        }
    }
    
    private func stopRecording() {
        audioRecorder?.stop()
        if let url = audioRecorder?.url, let fileName = recordedFileName {
            audioURL = url
            
            do {
                let audioData = try Data(contentsOf: url)
                let base64String = audioData.base64EncodedString()
                
                viewModel.saveAudioAnswer(
                    for: question.id,
                    base64Audio: base64String,
                    fileName: fileName
                )
            } catch {
                print("Ses dosyası okunamadı: \(error.localizedDescription)")
            }
        }
        isRecording = false
        audioRecorder = nil
    }
    
    private func startPlaying() {
        guard let url = audioURL else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
            isPlaying = true
            
            // Çalma bittiğinde
            audioPlayer?.delegate = AudioPlayerDelegate { finished in
                DispatchQueue.main.async {
                    isPlaying = !finished
                }
            }
        } catch {
            print("Oynatma başlatılamadı: \(error.localizedDescription)")
        }
    }
    
    private func stopPlaying() {
        audioPlayer?.stop()
        isPlaying = false
        audioPlayer = nil
    }
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

#Preview {
    AudioAnswerView(
        question: Question(
            questionText: "Ses kaydı yapınız",
            answerType: .audio
        )
    )
    .environmentObject(SurveyDetailViewModel(survey: Survey(
        title: "Test Anketi",
        description: "Test açıklaması",
        questions: []
    )))
} 