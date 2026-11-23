<?php
require 'db.php';

$requestId = (int)($_GET['request_id'] ?? 0);
if (!$requestId) {
    echo json_encode(['error' => 'request_id الزامی است']);
    exit;
}

$stmt = $pdo->prepare("SELECT r.status, c.id AS chat_id FROM chat_requests r LEFT JOIN chats c ON c.request_id = r.id WHERE r.id = ?");
$stmt->execute([$requestId]);
$row = $stmt->fetch();

if (!$row) {
    echo json_encode(['error' => 'یافت نشد']);
    exit;
}

echo json_encode([
    'status' => $row['status'],
    'chat_id' => $row['chat_id'] ? (int)$row['chat_id'] : null,
]);
