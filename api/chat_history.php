<?php
require 'db.php';

$chatId = (int)($_GET['chat_id'] ?? 0);
$role = ($_GET['role'] ?? 'user') === 'admin' ? 'admin' : 'user';
if (!$chatId) {
    echo json_encode(['error' => 'chat_id الزامی است']);
    exit;
}

$visible = $role === 'admin' ? 'deleted_all=0 AND deleted_for_admin=0' : 'deleted_all=0 AND deleted_for_user=0';
$stmt = $pdo->prepare("SELECT id, chat_id, sender, content, kind, file_path, created_at FROM chat_messages WHERE chat_id=? AND $visible ORDER BY id ASC");
$stmt->execute([$chatId]);
$rows = $stmt->fetchAll();
foreach ($rows as &$row) {
    $row['id'] = (int)$row['id'];
    $row['chat_id'] = (int)$row['chat_id'];
}
unset($row);

echo json_encode(['messages' => $rows]);
