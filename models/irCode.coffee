mongoose = require 'mongoose'
Schema = mongoose.Schema

schema = new Schema {
  code: [String],
  dispName: String,
  category: String,
  type: {
    name: String,
    value: String
  }
}

module.exports = mongoose.model 'ircodes', schema
