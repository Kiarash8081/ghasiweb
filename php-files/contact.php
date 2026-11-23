<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') exit(0);

require 'db.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $data = json_decode(file_get_contents('php://input'), true);
    if (!isset($data['name']) || !isset($data['email']) || !isset($data['message'])) {
        http_response_code(400);
        echo json_encode(['error' => 'missing fields']);
        exit;
    }
    
    $name = trim((string)$data['name']);
    $email = trim((string)$data['email']);
    $message = trim((string)$data['message']);
    if ($name === '' || $email === '' || $message === '') {
        http_response_code(400);
        echo json_encode(['error' => 'missing fields']);
        exit;
    }

    try {
        $stmt = $pdo->prepare("INSERT INTO contact_messages (name, email, message) VALUES (?, ?, ?)");
        $stmt->execute([mb_substr($name, 0, 120), mb_substr($email, 0, 190), mb_substr($message, 0, 4000)]);
        echo json_encode(['status' => 'ok', 'id' => (int)$pdo->lastInsertId()]);
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['error' => 'save failed']);
    }
    exit;
}

echo json_encode(['error' => 'method not allowed']);