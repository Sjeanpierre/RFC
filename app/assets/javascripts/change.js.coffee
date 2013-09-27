# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
window.rfChange = {};


$(document).ready ->
  $('.select2').select2()
  rfChange.bsfire()

$(document).on "click", ".editable-cancel, .editable-submit", ->
  $(".add").show()

$(document).on "click", ".editable-cancel", ->
  $('.adder a').last().remove()


rfChange.notify = (modalName)->
  watchButton = "##{modalName}Modal .modal-content .add-button"
  $(watchButton).click (e) ->
    e.stopPropagation()
    randomId = Math.floor(Math.random() * 1000001)
    uid = "#{modalName}_#{randomId}"
    editable = "<a href='#' data-pk='#{randomId}' id='#{uid}' class='editable editable-click inline-input' style=''></a>"
    editField = ".#{modalName}-list .adder"
    $(editField).append(editable)
    editFieldSelector = '#'+uid
    rfChange.initeditable(editFieldSelector,modalName)
    $(editFieldSelector).editable "toggle"
#    $(this).hide()

rfChange.initeditable = (selector,resourceName) ->
  $(selector).editable
    type: "text"
    mode: "inline"
    url: "/#{resourceName}/add"
    placement: "top"
    value: ""
    success: (response, newValue) ->
      rfChange.success(selector, newValue)
    error: (err) ->
      console.log "error"

rfChange.success = (selector,newValue) ->
  newData = "<li class='new'>#{newValue}</li>"
  $(selector).parent().append(newData)
  $(selector).remove()

rfChange.bsfire = ->
  modals = ['impact','status','system','change_type','priority']
  for modalName in modals
    modalSelector = "##{modalName}Modal"
    $(modalSelector).on "show.bs.modal", ->
      rfChange.notify(modalName)