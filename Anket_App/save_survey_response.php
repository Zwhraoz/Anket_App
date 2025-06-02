<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

// 🔒 Log dosyaları
$logPath = __DIR__ . "/json_log.txt";
$answerLogPath = __DIR__ . "/answer_debug.txt";
$errorLogPath = __DIR__ . "/error_log.txt";

// 🔍 Gelen JSON verisini kaydet
$raw = file_get_contents("php://input");
file_put_contents($logPath, $raw . "\n\n", FILE_APPEND);

// 🔧 Veritabanı bağlantı bilgileri
$host = "213.142.131.132";
$port = 3306;
$dbname = "mobilprogramlama";
$username = "mobil_program2025";
$password = "MBprogram2025*";

// 🔗 MySQL bağlantısı
$conn = new mysqli($host, $username, $password, $dbname, $port);
if ($conn->connect_error) {
    file_put_contents($errorLogPath, "DB bağlantı hatası: " . $conn->connect_error . "\n", FILE_APPEND);
    echo json_encode([
        "success" => false,
        "message" => "Veritabanı bağlantı hatası."
    ]);
    exit;
}

// 📦 JSON verisini işle
if (!$raw || trim($raw) === '') {
    echo json_encode(["success" => false, "message" => "POST verisi boş!"]);
    exit;
}

$data = json_decode($raw, true);
if (json_last_error() !== JSON_ERROR_NONE) {
    file_put_contents($errorLogPath, "JSON decode hatası: " . json_last_error_msg() . "\n", FILE_APPEND);
    echo json_encode([
        "success" => false,
        "message" => "Geçersiz JSON verisi: " . json_last_error_msg()
    ]);
    exit;
}

// ✅ Gerekli alan kontrolü
if (!isset($data["userId"], $data["surveyTitle"], $data["answers"])) {
    echo json_encode([
        "success" => false,
        "message" => "Eksik alanlar: userId, surveyTitle veya answers."
    ]);
    exit;
}

$user_id = $data["userId"];
$survey_title = $data["surveyTitle"];
$survey_description = $data["surveyDescription"] ?? "";
$answers = $data["answers"];

// 🔄 Cevapları veritabanına kaydet
foreach ($answers as $answer) {
    file_put_contents($answerLogPath, print_r($answer, true) . "\n", FILE_APPEND);

    $question_id = $answer["question_id"] ?? "";
    $answer_text = $answer["answer_text"] ?? "";
    $audio_url = $answer["audio_url"] ?? "";
    $signature_url = $answer["signature_url"] ?? "";
    
    // Cevap tipini belirle
    if (!empty($audio_url)) {
        $answer_type = "audio";
    } elseif (!empty($signature_url)) {
        $answer_type = "signature";
    } else {
        $answer_type = "text";
    }
    
    $options = ""; // Şimdilik boş, ileride çoktan seçmeli seçenekler için kullanılabilir

    // 🔐 Prepare & bind
    $stmt = $conn->prepare("
        INSERT INTO Survey_App2 
        (user_id, question_text, answer_text, answer_type, options, audio_url, signature_url, survey_title, survey_description, answer_date) 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())
    ");

    if (!$stmt) {
        file_put_contents($errorLogPath, "Prepare hatası: " . $conn->error . "\n", FILE_APPEND);
        echo json_encode(["success" => false, "message" => "Prepare hatası."]);
        exit;
    }

    $stmt->bind_param(
        "issssssss",
        $user_id,
        $question_id,
        $answer_text,
        $answer_type,
        $options,
        $audio_url,
        $signature_url,
        $survey_title,
        $survey_description
    );

    if (!$stmt->execute()) {
        file_put_contents($errorLogPath, "Execute hatası: " . $stmt->error . "\n", FILE_APPEND);
        echo json_encode(["success" => false, "message" => "Veritabanı kayıt hatası."]);
        $stmt->close();
        exit;
    }

    $stmt->close();
}

// 🟢 Başarılı yanıt
echo json_encode(["success" => true, "message" => "Tüm cevaplar başarıyla kaydedildi."]);
$conn->close();
?> 