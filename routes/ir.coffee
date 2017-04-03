express = require 'express'
router = express.Router()
IrCode = require '../models/irCode'

# ./ir -> DBにアクセスして赤外線データのリストを返す
router.get '/', (req, res, next) ->
  IrCode.find (err, item) ->
    if err
      return res.send false
    else
      return res.json { ircodes : item }

# ./ir/send -> 赤外線を送信する
router.post '/send', (req, res, next) ->
  console.log "[DEBUG] Sending IR..."
  console.log req.body.code

  _irData = req.body.code
  _irData.unshift req.body.isSafeMode

  spawn = require('child_process').spawn
  p = spawn './lib/apc_setIR', _irData
  p.stdout.setEncoding 'utf8'

  p.stdout.on 'data', (data) ->
    console.log data
    if ~data.indexOf "[APC-SETIR]"
      console.log "[DEBUG] SetIR is operating."
      res.send true

# ./ir/rcv -> 赤外線を受信して返す
router.get '/rcv', (req, res, next) ->
  console.log "[DEBUG] Receiving IR..."
  
  spawn = require('child_process').spawn
  p = spawn './lib/apc_getIR'
  p.stdout.setEncoding 'utf8'

  p.stdout.on 'data', (data) ->
    console.log data
    res.json { code: data }

# ./ir/regist -> 赤外線データを登録する
router.post '/regist', (req, res, next) ->
  ircode = new IrCode {
    code: req.body.code,
    dispName: req.body.dispName,
    category: req.body.category,
    type: req.body.type
  }

  ircode.save (err, ret) ->
    if err
      res.send false
    else
      res.send true


# ./ir/delete -> 赤外線データを削除する
router.post '/delete', (req, res, next) ->
  IrCode.remove {_id: req.body._id}, (err) ->
    if err
      console.log err
      res.send false
    else
      res.send true


# ./ir/edit -> 赤外線データを編集する
router.post '/edit', (req, res, next) ->
  updates = { code: req.body.code, dispName: req.body.dispName, category: req.body.category, type: req.body.type }

  IrCode.findOneAndUpdate {_id: req.body._id}, updates, {upsert:false, new: true}, (err, result) ->
    if err
      console.log err
      res.send false
    else
      res.send true


module.exports = router

