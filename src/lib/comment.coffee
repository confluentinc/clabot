'use strict'
fs   = require 'fs'
path = require 'path'

_      = require 'lodash'
{ Octokit } = require '@octokit/rest'

exports.getCommentBody = (signed, templates = {}, templateData) ->
  if arguments.length is 2
    templateData = templates
    templates = {}

  _.defaults templateData,
    image     : no
    link      : no
    maintainer: no
    sender    : no
    check     : no

  if signed == 'confirm'
    unless templates.confirmSigned
      templates.confirmSigned = fs.readFileSync path.resolve(__dirname,
          '../templates'
          'confirmSigned.template.md')
        , 'UTF-8'
    _.template templates.confirmSigned, templateData
  else if signed
    unless templates.alreadySigned
      templates.alreadySigned = fs.readFileSync path.resolve(__dirname,
          '../templates'
          'alreadySigned.template.md')
        , 'UTF-8'
    _.template templates.alreadySigned, templateData
  else
    unless templates.notYetSigned
      templates.notYetSigned = fs.readFileSync path.resolve(__dirname,
          '../templates'
          'notYetSigned.template.md')
        , 'UTF-8'
    _.template templates.notYetSigned, templateData

exports.send = (token, msg, callback) ->
  api = new Octokit {
    auth: token
  }

  api.rest.issues.createComment(msg).then (data) ->
    callback null, data
  .catch (err) ->
    callback err, null
