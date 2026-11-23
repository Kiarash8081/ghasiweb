<?php
header('Content-Type: application/json; charset=utf-8');

$dir = __DIR__ . '/data';
if (!is_dir($dir)) {
    mkdir($dir, 0755, true);
}
$file = $dir . '/views.json';
$today = date('Y-m-d');
$raw = is_file($file) ? file_get_contents($file) : '';
$data = json_decode($raw ?: '{}', true);
if (!is_array($data)) {
    $data = [];
}
$data[$today] = (isset($data[$today]) ? (int)$data[$today] : 0) + 1;
file_put_contents($file, json_encode($data));
echo '{"ok":true}';
