# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
window.rfChange = {};


$(document).on "click", ".editable-cancel, .editable-submit", ->
  $(".add").show()

$(document).on "click", ".editable-cancel", ->
  $('.adder a').last().remove()


rfChange.notify = ->
  $.fn.editable.defaults.mode = 'inline'
  $(".add").click (e) ->
    e.stopPropagation()
    randomID = Math.floor(Math.random() * 1000001)
    uid = 'impact_'+randomID
    editable = "<a href='#' data-pk='#{randomID}' id='#{uid}' class='editable editable-click inline-input' style=''></a>"
    $('.adder').append(editable)
    selector = '#'+uid
    rfChange.initeditable(selector)
    $(selector).editable "toggle"
    $(this).hide()




rfChange.initeditable = (selector) ->
  $(selector).editable
    type: "text"
    mode: "inline"
    url: "/change"
    placement: "top"
    value: ""
    title: "Enter New Impact"
    success: (response, newValue) ->
      rfChange.success(selector, newValue)
    error: (err) ->
      console.log "error"

rfChange.success = (selector,newValue) ->
  newData = "<li class='new'>#{newValue}</li>"
  $(selector).parent().append(newData)
  $(selector).remove()

rfChange.bsfire = ->
  $("#impactModal").on "show.bs.modal", ->
    rfChange.notify()