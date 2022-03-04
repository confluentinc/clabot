'use strict'

_      = require 'lodash'
{ Octokit } = require '@octokit/rest'

errorHandler = (err, res) ->
  msg = 'Fatal Error: GitHub refused to list Collaborators/Contributors'
  console.log msg
  console.log JSON.parse err
  res.send 500, msg

exports = module.exports = (res, sender, options, contractors, msg, callback) ->
  api = new Octokit {
    auth: options.token
  }

  collabs = (toBeSkipped, callback) ->
    api.rest.repos.listCollaborators(msg).then ({ data: collaborators }) ->
      _.each collaborators, (collaborator) ->
        toBeSkipped.push collaborator.login
      callback toBeSkipped
    .catch (err) ->
      errorHandler err, res

  contribs = (toBeSkipped, callback) ->
    api.rest.repos.listContributors(msg).then ({ data: contributors }) ->
      _.each contributors, (contributor) ->
        toBeSkipped.push contributor.login
      callback toBeSkipped
    .catch (err) ->
      errorHandler err, res

  skip = (toBeSkipped) ->
    if _.contains toBeSkipped, sender
      console.log   'Skipping Collaborator/Contributor'
      res.send 200, 'Skipping Collaborator/Contributor'
    else
      callback(contractors)

  if options.skipCollaborators and options.skipContributors
    collabs [], (toBeSkipped) ->
      contribs toBeSkipped, (toBeSkipped) ->
        skip toBeSkipped
  else if options.skipCollaborators and not options.skipContributors
    collabs [], (toBeSkipped) ->
      skip toBeSkipped
  else if options.skipContributors
    contribs [], (toBeSkipped) ->
      skip toBeSkipped
  else
    callback(contractors)



