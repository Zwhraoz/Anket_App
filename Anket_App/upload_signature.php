<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

// 🔒 Log dosyaları
$logPath = __DIR__ . "/signature_log.txt";
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
if (!isset($data["userId"], $data["fileName"], $data["signatureBase64"])) {
    echo json_encode([
        "success" => false,
        "message" => "Eksik alanlar: userId, fileName veya signatureBase64."
    ]);
    exit;
}

$user_id = $data["userId"];
$fileName = $data["fileName"];
$signatureBase64 = $data["signatureBase64"];

// Base64'ü temizle (varsa data:image/jpeg;base64, kısmını kaldır)
$signatureBase64 = preg_replace('/^data:image\/\w+;base64,/', '', $signatureBase64);

// 📁 İmza için klasör oluştur
$uploadDir = 'signatures/';
if (!file_exists($uploadDir)) {
    mkdir($uploadDir, 0777, true);
}

// 📝 Dosya yolu oluştur
$filePath = $uploadDir . $fileName;

try {
    // 💾 Base64'ü dosyaya kaydet
    $decodedSignature = base64_decode($signatureBase64);
    if (file_put_contents($filePath, $decodedSignature)) {
        // 🌐 Dosya URL'ini oluştur
        $fileUrl = 'https://mobilprogramlama.ardglobal.com.tr/Foto_ses_kaydi_imza_swift/signatures/' . $fileName;
        
        // 🔐 Veritabanına kaydet
        $stmt = $conn->prepare("
            INSERT INTO Survey_App2 
            (user_id, signature_url, answer_type, answer_date) 
            VALUES (?, ?, 'signature', NOW())
        ");

        if (!$stmt) {
            file_put_contents($errorLogPath, "Prepare hatası: " . $conn->error . "\n", FILE_APPEND);
            echo json_encode(["success" => false, "message" => "Prepare hatası."]);
            exit;
        }

        $stmt->bind_param("is", $user_id, $fileUrl);

        if (!$stmt->execute()) {
            file_put_contents($errorLogPath, "Execute hatası: " . $stmt->error . "\n", FILE_APPEND);
            echo json_encode(["success" => false, "message" => "Veritabanı kayıt hatası."]);
            $stmt->close();
            exit;
        }

        $stmt->close();
        
        echo json_encode([
            "success" => true,
            "message" => "İmza başarıyla yüklendi",
            "signature_url" => $fileUrl
        ]);
    } else {
        echo json_encode([
            "success" => false,
            "message" => "Dosya kaydedilemedi"
        ]);
    }
} catch (Exception $e) {
    file_put_contents($errorLogPath, "Hata: " . $e->getMessage() . "\n", FILE_APPEND);
    echo json_encode([
        "success" => false,
        "message" => "Hata: " . $e->getMessage()
    ]);
}

$conn->close();
?> 