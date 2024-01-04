export function deleteKeysWithPrefix(prefix) {
    var keysToDelete = [];

    // プリフィックスにマッチするキーを探す
    for (var i = 0; i < localStorage.length; i++) {
        var key = localStorage.key(i);
        if (key.startsWith(prefix)) {
            // ここで削除するとLSのindexが変わって全アイテムを処理できなくなるので一旦配列に格納
            keysToDelete.push(key);
        }
    }

    // キーを削除
    keysToDelete.forEach(function(key) {
        localStorage.removeItem(key);
    });
}

