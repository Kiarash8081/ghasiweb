<?php
error_reporting(E_ALL);
ini_set('display_errors', 0);

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') exit(0);

$host = 'localhost';
$dbname = 'mojdew_mojdew_mojde';
$user = 'mojdew_kiarash';
$pass = 'CHANGE_ME';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $user, $pass);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['error' => 'DB failed']);
    exit;
}

$pdo->exec("CREATE TABLE IF NOT EXISTS settings (`key` VARCHAR(64) PRIMARY KEY, value TEXT)");

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    try {
        $stmt = $pdo->prepare("SELECT value FROM settings WHERE `key` = 'background'");
        $stmt->execute();
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        echo json_encode(['background' => $row ? $row['value'] : 'grid']);
    } catch (Exception $e) {
        echo json_encode(['background' => 'grid']);
    }
    exit;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $data = json_decode(file_get_contents('php://input'), true);
    $bg = $data['background'] ?? 'grid';
    try {
        $stmt = $pdo->prepare("INSERT INTO settings (`key`, value) VALUES ('background', ?) ON DUPLICATE KEY UPDATE value = ?");
        $stmt->execute([$bg, $bg]);
        echo json_encode(['status' => 'ok', 'background' => $bg]);
    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode(['error' => $e->getMessage()]);
    }
    exit;
}