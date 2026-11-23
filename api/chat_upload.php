<?php
require 'db.php';

$chatId = (int)($_POST['chat_id'] ?? 0);
$sender = $_POST['sender'] ?? 'user';
$kind = $_POST['kind'] ?? '';

if (!$chatId || !in_array($sender, ['user', 'admin'], true) || !in_array($kind, ['image', 'video', 'voice'], true)) {
    echo json_encode(['error' => 'اطلاعات ناقص']);
    exit;
}

if ($sender === 'admin') {
    if (($_POST['user'] ?? '') !== 'kiarash' || ($_POST['pass'] ?? '') !== 'CHANGE_ME') {
        echo json_encode(['error' => 'دسترسی غیرمجاز']);
        exit;
    }
}

if (!isset($_FILES['file']) || $_FILES['file']['error'] !== UPLOAD_ERR_OK) {
    echo json_encode(['error' => 'فایل دریافت نشد']);
    exit;
}

$max = 10 * 1024 * 1024;
if ($_FILES['file']['size'] > $max) {
    echo json_encode(['error' => 'حجم فایل باید حداکثر ۱۰ مگابایت باشد']);
    exit;
}

$ext = strtolower(pathinfo($_FILES['file']['name'], PATHINFO_EXTENSION));
$allowed = [
    'image' => ['jpg', 'jpeg', 'png', 'gif', 'webp'],
    'video' => ['mp4', 'webm', 'mov'],
    'voice' => ['webm', 'ogg', 'mp3', 'm4a', 'wav', 'mp4'],
];
if (!in_array($ext, $allowed[$kind], true)) {
    echo json_encode(['error' => 'این نوع فایل مجاز نیست']);
    exit;
}

$check = $pdo->prepare("SELECT id FROM chats WHERE id=?");
$check->execute([$chatId]);
if (!$check->fetch()) {
    echo json_encode(['error' => 'چت پیدا نشد']);
    exit;
}

$dir = dirname(__DIR__) . '/uploads/chat';
if (!is_dir($dir) && !mkdir($dir, 0755, true)) {
    echo json_encode(['error' => 'پوشه ذخیره ساخته نشد']);
    exit;
}

$name = bin2hex(random_bytes(16)) . '.' . $ext;
$dest = $dir . '/' . $name;
if (!move_uploaded_file($_FILES['file']['tmp_name'], $dest)) {
    echo json_encode(['error' => 'ذخیره فایل انجام نشد']);
    exit;
}

$rel = 'uploads/chat/' . $name;
$stmt = $pdo->prepare("INSERT INTO chat_messages (chat_id, sender, content, kind, file_path) VALUES (?, ?, '', ?, ?)");
$stmt->execute([$chatId, $sender, $kind, $rel]);
$messageId = (int)$pdo->lastInsertId();

$row = $pdo->prepare("SELECT id, chat_id, sender, content, kind, file_path, created_at FROM chat_messages WHERE id=?");
$row->execute([$messageId]);
$saved = $row->fetch();
if ($saved) {
    $saved['id'] = (int)$saved['id'];
    $saved['chat_id'] = (int)$saved['chat_id'];
}

echo json_encode(['success' => true, 'message' => $saved]);
