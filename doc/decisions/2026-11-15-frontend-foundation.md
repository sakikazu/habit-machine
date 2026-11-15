# フロントエンド基盤からBootstrap 4を除去した判断

- 決定日: 2026-11-15
- 対象: Habit Machine
- 状態: 採用・移行完了

## 概要

Habit Machineでは、RailsのViewとVueコンポーネントの広い範囲でBootstrap 4、Font Awesome 4、jQuery、Bootstrap向け日時ピッカー、`sassc`を利用していた。

Rails 8.1・Vue 3への更新後もサービス自体は動作していたが、古いライブラリ同士の依存関係がフロントエンドの変更を難しくしていた。そのためBootstrap 5への更新ではなく、Bootstrapへの依存を段階的に除去し、画面固有のCSS、Tailwind CSS、Lucide、ネイティブJavaScript、Vueへ置き換えた。

この移行の目的は、見た目を大きく変更することではなく、現在のUIを維持しながら依存関係と実装責務を明確にすることだった。

## 移行前の課題

### Bootstrapの影響範囲が大きい

Bootstrap由来のグリッド、余白、ボタン、フォーム、カード、テーブル、ナビゲーションなどのクラスが多数の画面で使われていた。Bootstrapを単純に削除すると、文字サイズ、余白、横並び、レスポンシブ表示などが広範囲に変化する状態だった。

JavaScriptコンポーネントについても、モーダル、ドロップダウン、collapse、popover、日時ピッカーなどがBootstrapとjQueryに依存していた。

### 古い依存関係が連鎖している

主に次の依存が残っていた。

- Bootstrap 4
- Font Awesome 4
- jQuery / jQuery UI
- Bootstrap向けdatetime picker
- Moment.js
- `sassc` / `sassc-rails`

一つのUIを変更する場合でも、Rails Gem、npm、Sprockets、Webpack、Vueの複数経路を考慮する必要があった。

### UIの責務が分かりにくい

Bootstrapの汎用クラス、View内のインラインSass、ページ固有スタイル、Vueのscoped CSSが混在していた。どの指定が最終的な表示を作っているか判断しにくく、変更時の影響範囲も予測しづらかった。

## Bootstrap 5へ更新しなかった理由

Bootstrap 5はjQueryへ依存せず、現在も利用可能な選択肢である。Bootstrapを中心とした画面を今後も作る方針であれば、Bootstrap 4から5への更新は妥当だった。

一方、Habit Machineでは次の理由から採用しなかった。

- Vueコンポーネントと画面固有UIが増え、Bootstrapコンポーネントを使う場面が減っていた
- family画面などでTailwind CSSの利用を開始していた
- Bootstrap 5へ更新しても、既存クラスやコンポーネントの移行作業は必要だった
- Bootstrapを残すと、独自CSS、Tailwind、Bootstrapという三つの設計体系が共存する
- jQueryを除去しても、Bootstrap固有のマークアップとクラスへの依存は残る
- 必要な機能に対して、フレームワーク全体の影響範囲が大きかった

Bootstrap 5の品質や継続性が問題なのではなく、現在のHabit Machineの構成と今後の開発方針に対して、包括的なUIフレームワークを維持する利点が小さいと判断した。

## 採用した構成

### Rails View

Rails Viewでは、画面固有のクラスとSCSS/Sassを基本とする。繰り返し利用する小さな表示はhelperやpartialへまとめる。

Bootstrap由来クラスが残る従来画面については、`app/assets/stylesheets/legacy_utilities.scss`で必要な表示だけを再現している。

### Vue

操作を伴うUIはVueコンポーネントとして実装し、コンポーネント固有のスタイルはscoped CSSへ置く。

モーダル、日時選択、入力補助など、画面の状態を持つUIをDOM操作だけで実装しない。

### Tailwind CSS

family画面など、新しく整理した画面ではTailwind CSSを利用している。

既存画面を理由なく一括変換せず、画面単位で責務を完結できる場合に採用する。Tailwindのクラスと従来の画面固有CSSを同じ要素へ過剰に混在させない。

### アイコン

Font Awesome 4を削除し、Lucideへ移行した。

Lucideは線画を基本とするため、通常操作の編集、保存、日付、ピン留めなどに向いている。一方、家族共有など重要な状態表示では、アイコン単体ではなく、背景色と短いラベルを組み合わせたバッジを使用する。

ブランドロゴや塗りつぶし表現が必要になった場合も、すぐ別のアイコンライブラリを追加せず、用途と使用量を確認してから判断する。

### JavaScript

jQueryとjQuery UIを削除し、次の方法へ移行した。

- 単純なイベント処理: ネイティブJavaScript
- 状態を持つ画面UI: Vue
- HTTP通信: Axios
- ページ遷移: 既存のTurbolinks

Turbolinks遷移時にはイベントの重複登録とVueの状態を持つDOMのキャッシュに注意する。Vueアプリはページ差し替え前に破棄し、キャッシュには元のテンプレートを残す。

### Sass

`sassc` / `sassc-rails`を削除し、Dart Sassへ統一した。

View内のインラインSassはページ別スタイルシートへ移し、Viewは構造、スタイルシートは見た目を担当する構成へ整理した。

## 移行で得られたメリット

- Bootstrap、Font Awesome、jQuery、Moment.js、日時ピッカーなどの依存を削減できた
- Rails ViewとVueで、UIの実装場所が分かりやすくなった
- Bootstrap JavaScriptの初期化状態を考慮する必要がなくなった
- Turbolinks遷移時のイベント管理を明示できるようになった
- アイコンをVueコンポーネントまたはRails helperとして扱えるようになった
- UIをサービス固有の要件に合わせて調整しやすくなった
- 古いRails向けフロントエンドGemの影響を減らせた
- AIを含む開発支援でも、一般的なHTML、CSS、JavaScript、Vueとしてコードを理解しやすくなった

## 移行で発生したデメリット

### Bootstrapが暗黙に提供していた表示を再実装する必要がある

Bootstrapはコンポーネントだけでなく、次の基本表示も提供していた。

- `h1`〜`h6`のサイズ、太さ、行間
- ボタンのhover状態
- フォーム部品の高さと角丸
- input groupの連結表示
- グリッドとレスポンシブ幅
- ナビゲーションのactive表示
- カード、テーブル、badge、alertの基本表示

削除直後は、個々の画面に明確なエラーがなくても、余白や文字サイズが少しずつ変わった。最終的に実画面を確認しながら互換CSSと画面固有CSSを調整した。

### UI部品を自分たちで保守する必要がある

モーダル、popover、時刻選択などをサービス内で実装するため、アクセシビリティ、レスポンシブ表示、キーボード操作を自分たちで考慮する必要がある。

ただし、現在必要な機能へ限定できるため、汎用ライブラリの全仕様へ合わせる必要はない。

### LucideはFont Awesomeより存在感が弱い場合がある

Lucideは統一された線画アイコンであり、Font AwesomeのSolidアイコンより軽く見える。重要な意味をアイコンだけに持たせず、ラベル、背景色、枠線を組み合わせる必要がある。

## `legacy_utilities.scss`の位置付け

`legacy_utilities.scss`はBootstrapを再構築するための新しいフレームワークではない。Bootstrap由来クラスが残る従来画面を壊さず、段階的に移行するための互換層である。

当面は安定性を優先して維持する。今後画面を変更する際は、次の方針とする。

1. 新しいBootstrap互換クラスを安易に追加しない
2. 画面固有の意味を持つクラスへ移せる場合は移す
3. 利用箇所がなくなった互換クラスは削除する
4. 全削除を目的に大規模な置換を行わない

## Propshaftについて

Rails 8ではPropshaftが標準だが、現時点ではSprocketsを継続する。

現在も次の処理がSprocketsへ依存している。

- `dartsass-sprockets`によるSCSS/Sassのコンパイル
- `application.scss`のSprocketsディレクティブ
- `application.js`での`rails-ujs`、Turbolinks、共通JavaScript、Highchartsの結合
- Gemが提供するアセットパス

Propshaftへ移行しても、利用者が体感する機能や速度が大きく改善するわけではない。移行する場合は先にCSSビルドと`application.js`をSprocketsから分離し、Propshaftには完成済みアセットのdigest付与と配信だけを担当させる。

そのためPropshaft移行の緊急性は低く、独立した技術改善として扱う。

## 今後UIライブラリを導入する場合の判断基準

新しいUIライブラリを導入する場合は、次を確認する。

- 一つの画面だけでなく、複数画面で継続的に利用するか
- CSSだけでなくJavaScriptのライフサイクルがTurbolinksやVueと共存できるか
- Tree Shakingや個別importが可能か
- スマホ、キーボード、スクリーンリーダーへ対応しているか
- ライブラリを外す場合の影響範囲を把握できるか
- 既存のTailwind、画面固有CSS、Lucideと役割が重複しないか
- 保守状況、ライセンス、依存パッケージが許容できるか

便利さだけで包括的なフレームワークを導入せず、サービスで繰り返し発生する課題を解決できる場合に採用する。

## 移行前後の参照

デザインや挙動を比較できるよう、次のGitタグをBitbucketとGitHubへ保存している。

- `before-bootstrap-removal`: Bootstrap除去作業を始める直前
- `bootstrap-removal-complete`: Bootstrap除去と主要画面のUI調整を完了した時点

旧画面を確認する場合は、現在の作業ツリーを切り替えず、別worktreeを作成できる。

```bash
git worktree add ../habit-machine-before-bootstrap before-bootstrap-removal
```

## 結論

Bootstrap 4の削除は、短期的には多数の細かなUI調整を必要とした。一方で、依存関係とUI実装の責務が整理され、Habit Machine固有の画面を変更しやすい構成になった。

Bootstrap 5へ更新する選択肢も成立したが、現在の画面構成と今後の開発方針を考えると、Bootstrap自体への依存を終了した判断は妥当だった。

今後は独自のUIフレームワークを作るのではなく、画面固有CSS、Tailwind、Vue、Lucideを用途ごとに使い分け、共通化が必要になった部分だけを小さなコンポーネントとして切り出す。
