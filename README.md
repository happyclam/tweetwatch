TweetWatch
==========

Twitter Streaming APIを使って特定のタグが付けられたツイートを監視し、ツイート毎にツイート数を集計してグラフ表示するアプリケーション

* Information
  * ツイートをDBに溜め込むスクリプトをWebページから制御して使います
  * DBにツイートを保存するスクリプトはユーザ毎に10000以上のポートを消費していきます
  * 集計結果グラフ表示は認証不要、認証済みユーザは他のユーザ情報・タグ情報が見れます。認証ユーザの中のアドミンユーザー（admin=true）のみツイート集計スクリプトを起動できます。
  * 管理者メニューはありませんのでユーザにツイート集計スクリプトを制御する権限与えるためには、手動でadminカラムに't'をセットする必要があります`update users set admin='t' where id=xxx;`
  
* Ruby version = 2.0.0p353

* Rails version = 4.0.2

* Configuration
  * DBにはSQLite3を使用しています

* Database creation
  * `rake db:migrate`
  * `rake db:reset`

* Database initialization
  * `rake db:populate`

* How to run the test suite
  * `rake db:test:prepare`
  * `bundle exec rspec spec/`

* Deployment instructions

* ...


Please feel free to use a different markup language if you do not plan to run
<tt>rake doc:app</tt>.
