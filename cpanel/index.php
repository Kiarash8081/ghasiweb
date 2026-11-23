<?php
ini_set('display_errors', '0');

$root = __DIR__;
$idFile = $root . '/deploy-id.txt';
$stampFile = $root . '/.deploy-stamp';
$keepFile = $root . '/keep.txt';
$expected = is_file($idFile) ? trim((string)file_get_contents($idFile)) : '';
$current = is_file($stampFile) ? trim((string)file_get_contents($stampFile)) : '';

if ($expected !== '' && $current !== $expected && is_file($keepFile)) {
    $keep = [];
    foreach (file($keepFile, FILE_IGNORE_NEW_LINES) as $line) {
        $line = str_replace('\\', '/', trim((string)$line));
        if ($line !== '') {
            $keep[$line] = true;
        }
    }
    $keep['index.php'] = true;
    $keep['keep.txt'] = true;
    $keep['deploy-id.txt'] = true;
    $keep['.htaccess'] = true;

    $skipDirs = ['cgi-bin' => true, '.well-known' => true, 'mail' => true, 'data' => true];

    $sweep = function ($dir, $rel) use (&$sweep, $keep, $skipDirs) {
        $items = scandir($dir);
        if ($items === false) {
            return;
        }
        foreach ($items as $name) {
            if ($name === '.' || $name === '..') {
                continue;
            }
            if ($rel === '' && isset($skipDirs[$name])) {
                continue;
            }
            if (isset($name[0]) && $name[0] === '.' && $name !== '.htaccess') {
                continue;
            }
            $path = $dir . DIRECTORY_SEPARATOR . $name;
            $child = $rel === '' ? $name : $rel . '/' . $name;
            if (is_dir($path)) {
                if ($rel === '' && !in_array($name, ['assets', 'api', 'fonts'], true)) {
                    continue;
                }
                $sweep($path, $child);
                continue;
            }
            if (!isset($keep[$child])) {
                @unlink($path);
            }
        }
    };

    $sweep($root, '');
    file_put_contents($stampFile, $expected);
}

header('Content-Type: text/html; charset=UTF-8');
readfile($root . '/index.html');
