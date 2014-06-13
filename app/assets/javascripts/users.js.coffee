# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'ready page:load', ->
  url = '/tweets/check'
  dfd = $.ajax
    url: url
    format: 'script'
    data: {}
    method: 'get'
  promise = dfd.promise()
  promise.done((data, status, xhr) ->
  )
  promise.fail((xhr, status, error) ->
    alert(error)
  )
