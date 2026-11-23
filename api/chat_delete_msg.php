<?php
require 'db.php';

$data = json_decode(file_get_contents('php://input'), true);
$id = (int)($data['message_id'] ?? 0);
$chatId = (int)($data['chat_id'] ?? 0);
$scope = ($data['scope'] ?? '') === 'all' ? 'all' : 'me';
$role = ($data['role'] ?? 'user') === 'admin' ? 'admin' : 'user';

if (!$id || !$chatId) {
    echo json_encode(['error' => 'پیام پیدا نشد']);
    exit;
}

if ($role === 'admin') {
    if (($data['user'] ?? '') !== 'kiarash' || ($data['pass'] ?? '') !== 'CHANGE_ME') {
        echo json_encode(['error' => 'دسترسی غیرمجاز']);
        exit;
    }
}

$row = $pdo->prepare("SELECT id, file_path FROM chat_messages WHERE id=? AND chat_id=?");
$row->execute([$id, $chatId]);
$message = $row->fetch();
if (!$message) {
    echo json_encode(['error' => 'پیام پیدا نشد']);
    exit;
}

if ($scope === 'all') {
    $rel = str_replace('\\', '/', (string)($message['file_path'] ?? ''));
    if (strpos($rel, 'uploads/chat/') === 0) {
        $full = dirname(__DIR__) . '/' . $rel;
        if (is_file($full)) @unlink($full);
    }
    $pdo->prepare("UPDATE chat_messages SET deleted_all=1, content='', file_path=NULL, deleted_at=NOW() WHERE id=?")->execute([$id]);
} elseif ($role === 'admin') {
    $pdo->prepare("UPDATE chat_messages SET deleted_for_admin=1, deleted_at=NOW() WHERE id=?")->execute([$id]);
} else {
    $pdo->prepare("UPDATE chat_messages SET deleted_for_user=1, deleted_at=NOW() WHERE id=?")->execute([$id]);
}

echo json_encode(['success' => true]);
