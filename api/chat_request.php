<?php
require 'db.php';

$data = json_decode(file_get_contents('php://input'), true);
$name = trim($data['name'] ?? '');
$contact = trim($data['contact'] ?? '');
$message = trim($data['message'] ?? '');

if (!$name || !$contact || !$message) {
    echo json_encode(['error' => 'نام، راه ارتباطی و پیام الزامی است']);
    exit;
}

$name = mb_substr($name, 0, 120);
$contact = mb_substr($contact, 0, 190);
$message = mb_substr($message, 0, 4000);

try {
    $stmt = $pdo->prepare("INSERT INTO chat_requests (user_name, user_contact, message, status) VALUES (?, ?, ?, 'pending')");
    $stmt->execute([$name, $contact, $message]);

    echo json_encode([
        'success' => true,
        'request_id' => (int)$pdo->lastInsertId(),
    ]);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['error' => 'ذخیره پیام در دیتابیس انجام نشد']);
}
