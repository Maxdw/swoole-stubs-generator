<?php
$http = new Swoole\Http\Server("0.0.0.0", 8101);
$http->on("start", function ($server) {
    echo "Swoole HTTP server is started at http://127.0.0.1:8101\n";
});
$http->on("request", function ($request, $response) {
    $response->header("Content-Type", "text/plain");
    $response->end("Container is being used for Swoole stub generation\n");
});
$http->start();