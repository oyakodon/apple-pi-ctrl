express = require 'express'
router = express.Router()

# GET home page.
router.get '/', (req, res, next) ->
  res.render 'index'

# DEBUG MODE
router.get '/debug', (req, res, next) ->
  res.cookie 'isDebug', 'true', {maxAge: 900000, httpOnly: false}
  res.render 'index'

module.exports = router
