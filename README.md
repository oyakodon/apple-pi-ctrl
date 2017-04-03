# Apple Pi Controller
[![license](https://img.shields.io/github/license/oyakodon/apple-pi-ctrl.svg)]()

Raspberry Pi 3 の拡張ボード「ApplePi」(の主に赤外線)で遊ぶためのWEBアプリケーションです。  
* 「ApplePi」はトランジスタ技術2017年1月号の付録です
* <http://toragi.cqpub.co.jp/tabid/807/Default.aspx>

## 動作環境
- Node.js (`npm`)
  - 6.x または 7.x を推奨
- MongoDB
- CoffeeScript

動作を確認している環境は以下の通りです。  
- Raspberry Pi 3
  - Raspbian GNU/Linux 8.0 (jessie)
- Node.js v7.4.0
- MongoDB v2.4.10
- CoffeeScript version 1.12.3

## 使い方
### セットアップ
    git clone https://github.com/oyakodon/apple-pi-ctrl
    cd apple-pi-ctrl
    npm i
    sudo coffee ./bin/www.coffee

### 依存パッケージのインストール(未確認)
    sudo apt-get install -y mongodb
    sudo npm i -g coffeescript

Node.jsのインストールは <http://qiita.com/seibe/items/36cef7df85fe2cefa3ea> がとても参考になります。

## ライセンス
```
The MIT License (MIT)

Copyright (c) 2017 Riku Saitou <oykdn@oykdn.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
```

