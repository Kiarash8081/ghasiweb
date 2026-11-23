<?php
require 'db.php';

$data = json_decode(file_get_contents('php://input'), true);
if (($data['user'] ?? '') !== 'kiarash' || ($data['pass'] ?? '') !== 'CHANGE_ME') {
    echo json_encode(['error' => 'دسترسی غیرمجاز']);
    exit;
}

$stmt = $pdo->query("
  SELECT c.*,
    r.user_contact,
    (SELECT COUNT(*) FROM chat_messages m WHERE m.chat_id=c.id AND m.is_read=0 AND m.sender='user') AS unread,
    (SELECT content FROM chat_messages m WHERE m.chat_id=c.id ORDER BY id DESC LIMIT 1) AS last_message
  FROM chats c
  LEFT JOIN chat_requests r ON r.id = c.request_id
  ORDER BY c.id DESC
");

echo json_encode($stmt->fetchAll());
