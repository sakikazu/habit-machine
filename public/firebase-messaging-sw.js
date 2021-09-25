//
// NOTE: Firebase Cloud Messagingから呼ばれる規定のスクリプト
// TODO: まだわからないことが多く、とりあえず成功したけど技術が枯れるまでほっときたい（2020/05/01）
//  - tokenは変わるらしいが、それをFCMに指定しなくても、通知が来る。テストメッセージのときに使うくらい。今はFCMでアプリごとに送信しているけど、その使用者を特定して送る場合はトークン指定なのかな。そしてその場合はCurlとかでやるしかない、と
//  - プッシュ受信の方法が全然わからん。複数あるし、内容はどこで設定されたものなのか・・
//

// 1. FCMを使うための設定を書く
// todo: なんだこのimportは
importScripts('https://www.gstatic.com/firebasejs/7.14.2/firebase-app.js');
importScripts('https://www.gstatic.com/firebasejs/7.14.2/firebase-messaging.js');

const firebaseConfig = {
  apiKey: "AIzaSyBKrpWIhHnTTTqyDYVfqr3qaSb5fvob5Gg",
  authDomain: "habitmachine-17858.firebaseapp.com",
  databaseURL: "https://habitmachine-17858.firebaseio.com",
  projectId: "habitmachine-17858",
  storageBucket: "habitmachine-17858.appspot.com",
  messagingSenderId: "504029042223",
  appId: "1:504029042223:web:1d86b7e299b30934fe98da"
};
firebase.initializeApp(firebaseConfig);

const messaging = firebase.messaging();
console.log('messaging 2:', messaging)

// todo: 呼ばれるかわからないが、他の情報にならって置いとく
// これはオプショナルな気がする。が、この設定していても通知内容はFCMで設定したものだし、必要なのか？
// ウェブアプリがバックグラウンドで動いている場合にメッセージを処理する
// フォアグラウンドはfrontend.htmlの方だが、バックグラウンドはServiceWorkerで処理しなきゃなので、こちらに書く
// TODO: ここで設定しているTitleとか使われているのを見たことない。サーバーで内容を設定するのが自然だろうけど、なぜここで設定できるようになってるんだ？
messaging.setBackgroundMessageHandler(function(payload) {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);
  // Customize notification here
  const notificationTitle = 'Background Message Title';
  const notificationOptions = {
    body: 'Background Message body.',
    icon: '/firebase-logo.png'
  };
  return self.registration.showNotification(notificationTitle,
    notificationOptions);
});

// todo: ここだけで良さそう。上のsetBackgroundMessageHandlerは不要かも
// これもフォアグラウンド用らしい（https://qiita.com/sadnessOjisan/items/05bbca78bca3301d24b2）
// todo: じゃあonMessageは、、
// todo: ん？バックグラウンドでこの設定が使われていたぞ
// todo: eventからFCMの通知内容は取れる？
self.addEventListener('push', function (event) {
  console.log('[sw.js]Received a push message', event);
  var title = "習慣開始チェック(^o^)";
  var body = "がんばれーい！";

  event.waitUntil(
    self.registration.showNotification(title, {
      body: body,
      icon: '/dragonball-192.png',
      tag: 'push-notification-tag'
    })
  );
});
self.addEventListener('notificationclick', function (event) {
  event.notification.close();
  clients.openWindow("/habitodos");
}, false);

