<?php
require 'db.php';

$data = json_decode(file_get_contents('php://input'), true);
$user = $data['user'] ?? '';
$pass = $data['pass'] ?? '';

if ($user !== 'kiarash' || $pass !== 'CHANGE_ME') {
    echo json_encode(['error' => 'دسترسی غیرمجاز']);
    exit;
}

$action = $data['action'] ?? 'list';

if ($action === 'list') {
    $stmt = $pdo->query("SELECT * FROM chat_requests ORDER BY created_at DESC");
    echo json_encode($stmt->fetchAll());
    exit;
}

if ($action === 'accept') {
    $requestId = (int)$data['request_id'];

    $req = $pdo->prepare("SELECT * FROM chat_requests WHERE id=?");
    $req->execute([$requestId]);
    $row = $req->fetch();

    if (!$row) {
        echo json_encode(['error' => 'درخواست پیدا نشد']);
        exit;
    }

    $existing = $pdo->prepare("SELECT id FROM chats WHERE request_id=? ORDER BY id DESC LIMIT 1");
    $existing->execute([$requestId]);
    $chat = $existing->fetch();

    if ($chat) {
        $pdo->prepare("UPDATE chat_requests SET status='accepted' WHERE id=?")->execute([$requestId]);
        echo json_encode([
            'success' => true,
            'chat_id' => (int)$chat['id'],
            'user_name' => $row['user_name'],
        ]);
        exit;
    }

    try {
        $pdo->beginTransaction();
        $pdo->prepare("UPDATE chat_requests SET status='accepted' WHERE id=?")->execute([$requestId]);
        $pdo->prepare("INSERT INTO chats (request_id, user_name) VALUES (?, ?)")
            ->execute([$requestId, $row['user_name']]);
        $chatId = (int)$pdo->lastInsertId();
        if (!empty($row['message'])) {
            $pdo->prepare("INSERT INTO chat_messages (chat_id, sender, content) VALUES (?, 'user', ?)")
                ->execute([$chatId, $row['message']]);
        }
        $pdo->commit();
        echo json_encode([
            'success' => true,
            'chat_id' => $chatId,
            'user_name' => $row['user_name'],
        ]);
    } catch (PDOException $e) {
        if ($pdo->inTransaction()) $pdo->rollBack();
        http_response_code(500);
        echo json_encode(['error' => 'ساخت چت انجام نشد']);
    }
    exit;
}

if ($action === 'from_contact') {
    $name = mb_substr(trim($data['name'] ?? ''), 0, 120);
    $contact = mb_substr(trim($data['contact'] ?? ''), 0, 190);
    $message = mb_substr(trim($data['message'] ?? ''), 0, 4000);
    if (!$name || !$message) {
        echo json_encode(['error' => 'اطلاعات پیام ناقص است']);
        exit;
    }

    try {
        $pdo->beginTransaction();
        $pdo->prepare("INSERT INTO chat_requests (user_name, user_contact, message, status) VALUES (?, ?, ?, 'accepted')")
            ->execute([$name, $contact, $message]);
        $requestId = (int)$pdo->lastInsertId();
        $pdo->prepare("INSERT INTO chats (request_id, user_name) VALUES (?, ?)")
            ->execute([$requestId, $name]);
        $chatId = (int)$pdo->lastInsertId();
        $pdo->prepare("INSERT INTO chat_messages (chat_id, sender, content) VALUES (?, 'user', ?)")
            ->execute([$chatId, $message]);
        $pdo->commit();
        echo json_encode(['success' => true, 'chat_id' => $chatId, 'user_name' => $name]);
    } catch (PDOException $e) {
        if ($pdo->inTransaction()) $pdo->rollBack();
        http_response_code(500);
        echo json_encode(['error' => 'ساخت چت انجام نشد']);
    }
    exit;
}

if ($action === 'delete') {
    $chatId = (int)($data['chat_id'] ?? 0);
    if (!$chatId) {
        echo json_encode(['error' => 'گفتگو پیدا نشد']);
        exit;
    }

    $files = $pdo->prepare("SELECT file_path FROM chat_messages WHERE chat_id=? AND file_path IS NOT NULL AND file_path<>''");
    $files->execute([$chatId]);
    foreach ($files->fetchAll() as $file) {
        $rel = str_replace('\\', '/', (string)$file['file_path']);
        if (strpos($rel, 'uploads/chat/') !== 0) continue;
        $full = dirname(__DIR__) . '/' . $rel;
        if (is_file($full)) @unlink($full);
    }

    $pdo->prepare("DELETE FROM chat_messages WHERE chat_id=?")->execute([$chatId]);
    $pdo->prepare("DELETE FROM chats WHERE id=?")->execute([$chatId]);
    echo json_encode(['success' => true]);
    exit;
}

if ($action === 'reject') {
    $requestId = (int)$data['request_id'];
    $pdo->prepare("UPDATE chat_requests SET status='rejected' WHERE id=?")->execute([$requestId]);
    echo json_encode(['success' => true]);
    exit;
}

echo json_encode(['error' => 'action نامعتبر']);
