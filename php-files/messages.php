<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') exit(0);

require 'db.php';

$adminUser = 'kiarash';
$adminPass = 'CHANGE_ME';

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $user = $_GET['user'] ?? '';
    $pass = $_GET['pass'] ?? '';
    if ($user !== $adminUser || $pass !== $adminPass) {
        http_response_code(401);
        echo json_encode(['error' => 'unauthorized']);
        exit;
    }
    
    $stmt = $pdo->query("SELECT * FROM contact_messages ORDER BY created_at DESC LIMIT 100");
    echo json_encode($stmt->fetchAll(PDO::FETCH_ASSOC));
    exit;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $data = json_decode(file_get_contents('php://input'), true);
    if (!isset($data['user']) || $data['user'] !== $adminUser) {
        http_response_code(401);
        echo json_encode(['error' => 'unauthorized']);
        exit;
    }
    
    if (isset($data['action']) && $data['action'] === 'delete') {
        $stmt = $pdo->prepare("DELETE FROM contact_messages WHERE id = ?");
        $stmt->execute([$data['id']]);
        echo json_encode(['status' => 'ok']);
        exit;
    }
}

http_response_code(405);
echo json_encode(['error' => 'method not allowed']);