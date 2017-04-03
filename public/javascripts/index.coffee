'use strict'

class appCtrler
  constructor: ($scope, $cookies, $window, $http, $timeout) ->
    $scope.alerts = []

    $scope.categories = []
    $scope.irList = []
    $scope.typeList = [{value: "button", name: "ボタン"}, {value:"default", name: "デフォルト"}]
    $scope.count_ir_button = {}
    
    $scope.newIR = { canInputCategory: false }
    $scope.delIR = { IR: {}}
    $scope.chkbox = { isSafeMode: false }

    $scope.isDebug = $cookies.get 'isDebug'
    $scope._debug_edit = {}

    # 全ての要素を取得し、カテゴリのリストも作る
    LoadJson = () ->
      $http.get './ir'
          .then (res) ->
              $scope.irList = res.data.ircodes
              angular.forEach $scope.irList, (v, idx, arr) ->
                  isUnique = true
                  angular.forEach $scope.categories, (_v, _idx, _arr) ->
                      if _v is v.category
                        isUnique = false
                  if isUnique
                    $scope.categories.push v.category
                    $scope.count_ir_button[v.category] = 0
                  $scope.count_ir_button[v.category]++ if v.type.value is "button"

          , (res) ->
              $scope.alerts.push {msg: "赤外線リストの取得中にエラーが発生しました。"}
              t = $timeout ->
                $scope.alerts.shift()
              , 5000

    LoadJson()

    # 赤外線受光ボタンクリック
    $scope.BtnRcvIRClicked = () ->
        $http.get './ir/rcv'
            .then (res) ->
                $scope.newIR._code = res.data.code
                $scope.newIR.code = res.data.code.split " "

            , (res) ->
                $scope.alerts.push {msg: "赤外線を検出できませんでした。"}
                t = $timeout ->
                  $scope.alerts.shift()
                , 5000

    # 赤外線登録ボタンクリック
    $scope.BtnRegIRClicked = () ->
        if $scope.newIR.canInputCategory
          $scope.newIR.category = $scope.newIR._category_input
        else
          $scope.newIR.category = $scope.newIR._category_select

        $http.post './ir/regist', $scope.newIR
            .then (res) ->
              $scope.alerts.push {type:"success", msg: "赤外線データの登録が完了しました。"}
              $scope.newIR = { canInputCategory: false }
              LoadJson()

            , (res) ->
              $scope.alerts.push {msg: "登録時にエラーが発生しました。"}
        t = $timeout ->
          $scope.alerts.shift()
        , 5000
    
    # 赤外線ボタンクリック時
    $scope.BtnSendIRClicked = (item) ->
        item.isSafeMode = $scope.chkbox.isSafeMode
        $http.post './ir/send', item
            .then (res) ->
              $scope.alerts.push {type:"success", msg: "赤外線を送信しました。"}
            , (res) ->
              $scope.alerts.push {msg: "赤外線の送信中にエラーが発生しました。"}
        t = $timeout ->
          $scope.alerts.shift()
        , 5000

    # 赤外線削除クリック時
    $scope.BtnDelIRClicked = () ->
        $http.post './ir/delete', $scope.delIR.IR
            .then (res) ->
              $scope.alerts.push {type:"success", msg: "赤外線データを削除しました。"}
              LoadJson()

            , (res) ->
              $scope.alerts.push {msg: "削除中にエラーが発生しました。"}
        t = $timeout ->
          $scope.alerts.shift()
        , 5000

    # ボタンテキストの省略
    $scope.BtnTextAbbreviate = (text) ->
      len = 3
      len = 2 if text.match(/[^A-Za-z0-9]+/)

      if len < text.length
        return text.substring(0, len - 1) + "…"
      else
        return text

    # アラートを閉じる
    $scope.CloseAlertClicked = (index) -> $scope.alerts.splice index, 1

    # カテゴリ切り替え
    $scope.BtnChCatClicked = () -> $scope.newIR.canInputCategory = !$scope.newIR.canInputCategory

    # ------------------------------------
    # DEBUG用
    # ------------------------------------
    #IR登録ボタンクリック時
    $scope.BtnDebugRegIRClicked = () ->
      dlg = $window.confirm "このアクションはデバッグ用です。開発者以外の利用は推奨されません。このデータを登録しますか？"
      if dlg
        _irData = angular.fromJson $scope._debug_new_ir
        $http.post './ir/regist', _irData
          .then (res) ->
            $scope.alerts.push {type:"success", msg: "赤外線データの登録が完了しました。"}
            $scope._debug_new_ir = {}
            LoadJson()

          , (res) ->
            $scope.alerts.push {msg: "登録時にエラーが発生しました。"}

      else
        $scope.alerts.push {type: "info", msg: "キャンセルされました。"}

      t = $timeout ->
        $scope.alerts.shift()
      , 5000

    # IR編集
    # コンボボックス
    $scope.SelectDebugChanged = () ->
      $scope._debug_edit.json = angular.toJson($scope._debug_edit.selected, true)

    # 編集ボタン
    $scope.BtnDebugEditIRClicked = () ->
      dlg = $window.confirm "このアクションはデバッグ用です。開発者以外の利用は推奨されません。このデータを登録しますか？"
      if dlg
        _irData = angular.fromJson $scope._debug_edit.json
        $http.post './ir/edit', _irData
          .then (res) ->
            $scope.alerts.push {type:"success", msg: "赤外線データの編集が完了しました。"}
            $scope._debug_edit_ir = {}
            LoadJson()

          , (res) ->
            $scope.alerts.push {msg: "登録時にエラーが発生しました。"}

      else
        $scope.alerts.push {type: "info", msg: "キャンセルされました。"}

      t = $timeout ->
        $scope.alerts.shift()
      , 5000

app = angular.module("apc-app", ['ngCookies', 'ngAnimate', 'ngSanitize', 'ui.bootstrap'])

app.controller "apc-ctrl", appCtrler

