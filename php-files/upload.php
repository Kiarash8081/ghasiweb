<?php
error_reporting(E_ALL);
ini_set('display_errors', 0);

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') exit(0);

$adminUser = 'kiarash';
$adminPass = 'CHANGE_ME';

if (!isset($_POST['user']) || $_POST['user'] !== $adminUser || !isset($_POST['pass']) || $_POST['pass'] !== $adminPass) {
    http_response_code(401);
    echo json_encode(['error' => 'unauthorized']);
    exit;
}

if (!isset($_FILES['file'])) {
    http_response_code(400);
    echo json_encode(['error' => 'no file']);
    exit;
}

$file = $_FILES['file'];
$ext = strtolower(pathinfo($file['name'], PATHINFO_EXTENSION));
$allowed = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'svg'];

if (!in_array($ext, $allowed)) {
    http_response_code(400);
    echo json_encode(['error' => 'invalid type']);
    exit;
}

if ($file['size'] > 5 * 1024 * 1024) {
    http_response_code(400);
    echo json_encode(['error' => 'too large']);
    exit;
}

$newName = 'img-' . time() . '-' . rand(1000, 9999) . '.' . $ext;
$targetDir = __DIR__ . '/uploads/';

if (!is_dir($targetDir)) {
    mkdir($targetDir, 0755, true);
}

$targetFile = $targetDir . $newName;

if (move_uploaded_file($file['tmp_name'], $targetFile)) {
    echo json_encode(['status' => 'ok', 'url' => './uploads/' . $newName]);
} else {
    http_response_code(500);
    echo json_encode(['error' => 'upload failed']);
}