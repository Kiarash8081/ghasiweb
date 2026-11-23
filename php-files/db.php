<?php
$host = 'localhost';
$dbname = 'mojdew_mojdew_mojde';
$user = 'mojdew_kiarash';
$pass = 'CHANGE_ME';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $user, $pass);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $pdo->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
    $pdo->exec("CREATE TABLE IF NOT EXISTS contact_messages (
        id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(120) NOT NULL,
        email VARCHAR(190) NOT NULL,
        message TEXT NOT NULL,
        is_read TINYINT(1) NOT NULL DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['error' => 'DB connection failed']);
    exit;
}