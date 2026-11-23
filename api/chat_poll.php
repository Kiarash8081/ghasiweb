<?php
require 'db.php';

$chatId = (int)($_GET['chat_id'] ?? 0);
$lastId = (int)($_GET['last_id'] ?? 0);
$role = ($_GET['role'] ?? 'user') === 'admin' ? 'admin' : 'user';
$since = (int)($_GET['since'] ?? 0);
if ($since <= 0) $since = time();

if (!$chatId) {
    echo json_encode(['error' => 'chat_id الزامی است']);
    exit;
}

$visible = $role === 'admin' ? 'deleted_all=0 AND deleted_for_admin=0' : 'deleted_all=0 AND deleted_for_user=0';
$hidden = $role === 'admin' ? '(deleted_all=1 OR deleted_for_admin=1)' : '(deleted_all=1 OR deleted_for_user=1)';

$start = time();
$timeout = 15;

while (time() - $start < $timeout) {
    $stmt = $pdo->prepare("SELECT id, chat_id, sender, content, kind, file_path, created_at FROM chat_messages WHERE chat_id=? AND id>? AND $visible ORDER BY id ASC");
    $stmt->execute([$chatId, $lastId]);
    $rows = $stmt->fetchAll();

    $gone = $pdo->prepare("SELECT id FROM chat_messages WHERE chat_id=? AND deleted_at IS NOT NULL AND UNIX_TIMESTAMP(deleted_at) > ? AND $hidden");
    $gone->execute([$chatId, $since]);
    $removed = array_map('intval', array_column($gone->fetchAll(), 'id'));

    if (count($rows) > 0 || count($removed) > 0) {
        if ($role === 'admin') {
            $pdo->prepare("UPDATE chat_messages SET is_read=1 WHERE chat_id=? AND sender='user' AND is_read=0")
                ->execute([$chatId]);
        } else {
            $pdo->prepare("UPDATE chat_messages SET is_read=1 WHERE chat_id=? AND sender='admin' AND is_read=0")
                ->execute([$chatId]);
        }
        foreach ($rows as &$row) {
            $row['id'] = (int)$row['id'];
            $row['chat_id'] = (int)$row['chat_id'];
        }
        unset($row);
        echo json_encode(['messages' => $rows, 'removed' => $removed, 'now' => time()]);
        exit;
    }

    sleep(1);

    if (connection_aborted()) exit;
}

echo json_encode(['messages' => [], 'removed' => [], 'now' => time()]);
