<?php
header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: no-store, no-cache, must-revalidate');
header('Pragma: no-cache');

$host = 'localhost';
$dbname = 'mojdew_mojdew_mojde';
$user = 'mojdew_kiarash';
$pass = 'CHANGE_ME';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $user, $pass);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $pdo->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
    $pdo->exec("CREATE TABLE IF NOT EXISTS portfolio_projects (
        id VARCHAR(64) PRIMARY KEY,
        host VARCHAR(190) NOT NULL,
        url TEXT NOT NULL,
        sort_order INT NOT NULL DEFAULT 0
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
    $pdo->exec("CREATE TABLE IF NOT EXISTS settings (`key` VARCHAR(64) PRIMARY KEY, value TEXT)");
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['error' => 'DB connection failed']);
    exit;
}

function portfolioSaved(PDO $pdo): bool {
    $stmt = $pdo->prepare("SELECT value FROM settings WHERE `key` = 'portfolio_saved'");
    $stmt->execute();
    $row = $stmt->fetch();
    return $row && $row['value'] === '1';
}

function markPortfolioSaved(PDO $pdo): void {
    $stmt = $pdo->prepare("INSERT INTO settings (`key`, value) VALUES ('portfolio_saved', '1') ON DUPLICATE KEY UPDATE value = '1'");
    $stmt->execute();
}

function keepOnResume(array $row): bool {
    $blob = strtolower((string)($row['host'] ?? '') . ' ' . (string)($row['url'] ?? ''));
    if (strpos($blob, 'pvice') !== false) return true;
    if (strpos($blob, 'cafe') !== false) return true;
    $raw = (string)($row['host'] ?? '') . (string)($row['url'] ?? '');
    return function_exists('mb_strpos') ? mb_strpos($raw, 'کافه') !== false : strpos($raw, 'کافه') !== false;
}

function pruneResumeOnce(PDO $pdo): void {
    $stmt = $pdo->prepare("SELECT value FROM settings WHERE `key` = 'portfolio_keep_pvice_cafe'");
    $stmt->execute();
    $row = $stmt->fetch();
    if ($row && $row['value'] === '1') return;

    $rows = $pdo->query("SELECT id, host, url FROM portfolio_projects")->fetchAll();
    $del = $pdo->prepare("DELETE FROM portfolio_projects WHERE id = ?");
    foreach ($rows as $item) {
        if (!keepOnResume($item)) $del->execute([$item['id']]);
    }
    $mark = $pdo->prepare("INSERT INTO settings (`key`, value) VALUES ('portfolio_keep_pvice_cafe', '1') ON DUPLICATE KEY UPDATE value = '1'");
    $mark->execute();
}

$managed = portfolioSaved($pdo);
$count = (int)$pdo->query("SELECT COUNT(*) FROM portfolio_projects")->fetchColumn();
$jsonFile = __DIR__ . '/data/projects.json';
if (!$managed && $count === 0 && is_file($jsonFile)) {
    $old = json_decode((string)file_get_contents($jsonFile), true);
    if (is_array($old)) {
        $stmt = $pdo->prepare("INSERT IGNORE INTO portfolio_projects (id, host, url, sort_order) VALUES (?, ?, ?, ?)");
        $i = 0;
        foreach ($old as $item) {
            if (!is_array($item) || empty($item['url'])) continue;
            $stmt->execute([
                substr((string)($item['id'] ?? ('p' . $i)), 0, 64),
                substr((string)($item['host'] ?? ''), 0, 190),
                (string)$item['url'],
                $i,
            ]);
            $i++;
        }
    }
}

pruneResumeOnce($pdo);

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $rows = $pdo->query("SELECT id, host, url FROM portfolio_projects ORDER BY sort_order, id")->fetchAll();
    echo json_encode([
        'managed' => portfolioSaved($pdo),
        'projects' => $rows,
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

$raw = file_get_contents('php://input');
$raw = preg_replace('/^\xEF\xBB\xBF/', '', (string)$raw);
$data = json_decode($raw, true);
if (!is_array($data) || ($data['user'] ?? '') !== 'kiarash' || ($data['pass'] ?? '') !== 'CHANGE_ME') {
    http_response_code(403);
    echo json_encode(['error' => 'forbidden']);
    exit;
}

$projects = $data['projects'] ?? [];
if (!is_array($projects)) $projects = [];

try {
    $pdo->beginTransaction();
    $pdo->exec("DELETE FROM portfolio_projects");
    $stmt = $pdo->prepare("INSERT INTO portfolio_projects (id, host, url, sort_order) VALUES (?, ?, ?, ?)");
    $used = [];
    $i = 0;
    foreach ($projects as $item) {
        if (!is_array($item) || empty($item['url'])) continue;
        $id = substr((string)($item['id'] ?? ('p' . $i)), 0, 60);
        if ($id === '' || isset($used[$id])) $id = substr($id . '-' . $i, 0, 64);
        $used[$id] = true;
        $stmt->execute([
            $id,
            substr((string)($item['host'] ?? ''), 0, 190),
            (string)$item['url'],
            $i,
        ]);
        $i++;
    }
    markPortfolioSaved($pdo);
    $pdo->commit();
} catch (Exception $e) {
    if ($pdo->inTransaction()) $pdo->rollBack();
    http_response_code(500);
    echo json_encode(['error' => 'save failed']);
    exit;
}

echo json_encode(['status' => 'ok']);
