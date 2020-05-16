# Airi

Airi is android build script on Jenkins.  
Jenkins用Androidビルドスクリプト [愛理](http://palette.clearrave.co.jp/product/mashiro/chara_airi.html)


## 概要

- AndroidのカスタムROMをJenkins上でビルドするためのスクリプトです。
- [lindwurm/madoka](https://github.com/lindwurm/madoka)をベースに、Jenkinsの変数で解決、設定を扱いやすく変更した物です。
    - ですので、Jenkinsの変数を正しく設定しないと動きません。
    - `repo sync`は別のjenkinsの別プロジェクトで解決するようにしたため、このスクリプトでrepo syncは不可能です。

## スクリプトの依存ソフトウェア

- [glynnbird/toot](https://github.com/glynnbird/toot)

## 各スクリプトの説明

 - `pre_process.sh`  
    前処理を実施するスクリプト
    - 成果物を保存するディレクトリを作成  
    - toot
 - `build.sh`
    実際にビルドをするスクリプト
    - `make clean`
    - ccacheのキャッシュ量設定
    - ビルド
 - `post_process.sh`
    後処理を実施するスクリプト
    - 成果物のコピー
        - log
        - rom zip
        - rom zip md5sum
        - changelog
    - ビルド時間の計算
    - pushbulletへの通知
    - toot

## Jenkinsに設定する変数

### プラグインに依存して設定する物

- `BUILD_TIMESTAMP`  
    [Build Timestamp](https://plugins.jenkins.io/build-timestamp/)に依存。  
    `Jenkinsの管理`→`システムの設定`→`Build Timestamp`を有効にし、パラメータを以下の様に設定する。
    - Timezone `UTC`
    - Pattern `yyyyMMdd_HHmmss`
- `START_BUILD_DATETIME`  
    `BUILD_TIMESTAMP`と同様に[Build Timestamp](https://plugins.jenkins.io/build-timestamp/)に依存。  
    `Build Timestamp`の設定に`Export more variables`を追加して、パラメータを以下の様にする。
    - Name `START_BUILD_DATETIME`
    - Pattern `yyyy-MM-dd HH:mm:ss`
    - Shift timestamp `- 0 days 0 hours 0 minutes`
- PUSHBULLET_TOKEN
    [Mask Passwords](https://plugins.jenkins.io/mask-passwords/)に依存。  
    このプラグインを追加後、プロジェクト→`設定`→`ビルドのパラメータ化`の`パラメータの追加`に`パスワード`が現れるので追加する。  
    `デフォルト値`にPushbulletで発行したAPI keyを入力しておく。


### ビルドパラメータに対して設定する物

- `BUILD_DIR`  
    型:テキスト　または　選択  
    ビルドディレクトリの指定。ビルドするROMのファイルを指定する。  
- `DEVICE`  
    型:テキスト　または　選択  
    ビルドするデバイスのコードネームを指定する。
- `TOOT`   
    型:真偽値  
    mastodonにtootするかしないか設定する。
- `CCACHE_DIR`  
    型:テキスト  
    cchacheの参照先を設定する。
- `CCACHE_CAP`  
    型:テキスト  
    ccacheのキャッシュ容量を指定する。
- `LOG_DIR`  
    型:テキスト  
    ログファイルの出力先を指定する。
- `ROM_DIR`  
    型:テキスト  
    ROMのzip出力先を指定する。
- `MAKE_CLEAN`  
    型:真偽値  
    ビルドする前に`make clean`を実行するか指定する。
- `BUILD_TYPE`  
    型:選択　または　テキスト  
    FlokoROMをどのタイプでビルドするか指定する。
    - UNOFFICAL
    - OFFICAL
    - EXPERIMENTAL
    - 別に上記以外の文字列を好きに入れて大丈夫(いいのか？)
- `TOOT_TAG`  
    型:テキスト  
    tootするときのタグを指定する。`#`からはじめる  
    例:`#AndroidBuildBattle`


## ライセンス

MIT

## 作者

- 爪楊枝
    - Mastodon: [@tumayouzi@mstdn.maud.io](https://mstdn.maud.io/@tumayouzi)
    - Github: [@tumayouzi](https://github.com/tumayouzi)
    - Website: [www.tooth-pick.xyz](https://www.tooth-pick.xyz/)