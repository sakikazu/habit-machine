//
// PWAのService Worker
//
// - このファイルを置いたパス配下がSWのscopeとなるので、
//   public直下に置いて、ドメイン配下がscopeになるようにする
//

// Mini-infobar表示（PWAインストールの案内）
self.addEventListener('fetch', function(e) {
  // ここは空でもOK
})
