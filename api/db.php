<?php
header('Content-Type: application/json; charset=utf-8');

$host = 'localhost';
$dbname = 'mojdew_mojdew_mojde';
$user = 'mojdew_kiarash';
$pass = 'CHANGE_ME';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $user, $pass);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $pdo->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
    ensureSchema($pdo);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['error' => 'DB connection failed']);
    exit;
}

function ensureSchema(PDO $pdo): void {
    $pdo->exec("CREATE TABLE IF NOT EXISTS contact_messages (
        id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(120) NOT NULL,
        email VARCHAR(190) NOT NULL,
        message TEXT NOT NULL,
        is_read TINYINT(1) NOT NULL DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

    $pdo->exec("CREATE TABLE IF NOT EXISTS chat_requests (
        id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
        user_name VARCHAR(120) NOT NULL,
        user_contact VARCHAR(190) NOT NULL,
        message TEXT NULL,
        status ENUM('pending','accepted','rejected') NOT NULL DEFAULT 'pending',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

    try {
        $pdo->exec("ALTER TABLE chat_requests ADD COLUMN message TEXT NULL");
    } catch (PDOException $e) {
        // ستون از قبل وجود دارد
    }

    $pdo->exec("CREATE TABLE IF NOT EXISTS chats (
        id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
        request_id INT UNSIGNED NULL,
        user_name VARCHAR(120) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

    $pdo->exec("CREATE TABLE IF NOT EXISTS chat_messages (
        id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
        chat_id INT UNSIGNED NOT NULL,
        sender ENUM('user','admin') NOT NULL,
        content TEXT NOT NULL,
        kind ENUM('text','image','video','voice') NOT NULL DEFAULT 'text',
        file_path VARCHAR(255) NULL,
        is_read TINYINT(1) NOT NULL DEFAULT 0,
        deleted_for_user TINYINT(1) NOT NULL DEFAULT 0,
        deleted_for_admin TINYINT(1) NOT NULL DEFAULT 0,
        deleted_all TINYINT(1) NOT NULL DEFAULT 0,
        deleted_at DATETIME NULL DEFAULT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        INDEX idx_chat_messages_chat (chat_id, id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

    try {
        $pdo->exec("ALTER TABLE chat_messages ADD COLUMN kind ENUM('text','image','video','voice') NOT NULL DEFAULT 'text'");
    } catch (PDOException $e) {
    }
    try {
        $pdo->exec("ALTER TABLE chat_messages ADD COLUMN file_path VARCHAR(255) NULL");
    } catch (PDOException $e) {
    }
    foreach ([
        "deleted_for_user TINYINT(1) NOT NULL DEFAULT 0",
        "deleted_for_admin TINYINT(1) NOT NULL DEFAULT 0",
        "deleted_all TINYINT(1) NOT NULL DEFAULT 0",
        "deleted_at DATETIME NULL DEFAULT NULL",
    ] as $definition) {
        try {
            $pdo->exec("ALTER TABLE chat_messages ADD COLUMN $definition");
        } catch (PDOException $e) {
        }
    }
}
