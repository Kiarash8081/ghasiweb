<?php
require 'db.php';

$data = json_decode(file_get_contents('php://input'), true);
$chatId = (int)($data['chat_id'] ?? 0);
$sender = $data['sender'] ?? 'user';
$content = trim($data['content'] ?? '');

if (!$chatId || !$content) {
    echo json_encode(['error' => 'اطلاعات ناقص']);
    exit;
}

if (!in_array($sender, ['user', 'admin'])) {
    echo json_encode(['error' => 'sender نامعتبر']);
    exit;
}

if ($sender === 'admin') {
    if (($data['user'] ?? '') !== 'kiarash' || ($data['pass'] ?? '') !== 'CHANGE_ME') {
        echo json_encode(['error' => 'دسترسی غیرمجاز']);
        exit;
    }
}

$check = $pdo->prepare("SELECT id FROM chats WHERE id=?");
$check->execute([$chatId]);
if (!$check->fetch()) {
    echo json_encode(['error' => 'چت پیدا نشد']);
    exit;
}

$stmt = $pdo->prepare("INSERT INTO chat_messages (chat_id, sender, content) VALUES (?, ?, ?)");
$stmt->execute([$chatId, $sender, mb_substr($content, 0, 4000)]);
$messageId = (int)$pdo->lastInsertId();

$row = $pdo->prepare("SELECT id, chat_id, sender, content, kind, file_path, created_at FROM chat_messages WHERE id=?");
$row->execute([$messageId]);
$saved = $row->fetch();
if ($saved) {
    $saved['id'] = (int)$saved['id'];
    $saved['chat_id'] = (int)$saved['chat_id'];
}

echo json_encode(['success' => true, 'message_id' => $messageId, 'message' => $saved]);
