# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
window.rfChange = {};

MODAL_NAMES = {'priority-adder': 'priority', 'status-adder': 'status', 'system-adder': 'system', 'change-type-adder': 'changeType', 'impact-adder': 'impact'}

$(document).ready ->
  $('.select2').select2()
  $('#priority-adder, #status-adder, #system-adder, #change-type-adder, #impact-adder').click (clickevent) ->
    rfChange.modalhandler(clickevent)
  rfChange.titleCounter()


$(document).on "click", ".editable-cancel, .editable-submit", ->
  $(".add").show()

$(document).on "click", ".editable-cancel", ->
  $('.adder a').last().remove()

rfChange.titleCounter = ->
  $("#title_label").simplyCountable
    counter: "#counter"
    countType: "characters"
    maxCount: 80
    strictMax: false
    countDirection: "down"
    safeClass: "safe-count"
    overClass: "over-count"
    thousandSeparator: ","
    onOverCount: ->
      rfChange.overCount()
    onSafeCount: ->
      rfChange.underCount()


rfChange.modalhandler = (clickevent) ->
  idValue = clickevent.currentTarget.attributes.id.value
  modalName = "#{MODAL_NAMES[idValue]}Modal"
  $("##{modalName}").modal('show')
  rfChange.handleAdd(MODAL_NAMES[idValue])
  rfChange.bindClose(modalName, idValue)

rfChange.bindClose = (modalName, idValue) ->
  $("##{modalName}").on 'hide.bs.modal', ->
    newResourceListItems = "##{modalName} ul li.new"
    rfChange.replaceInput(MODAL_NAMES[idValue]) if $(newResourceListItems).length isnt 0
    $(newResourceListItems).removeClass('new').addClass('notsonew');

rfChange.handleAdd = (modalId)->
  watchButton = "##{modalId}Modal .modal-content .add-button"
  $(watchButton).click (e) ->
    e.stopPropagation()
    randomId = Math.floor(Math.random() * 1000001)
    uid = "#{modalId}_#{randomId}"
    editable = "<a href='#' data-pk='#{randomId}' id='#{uid}' class='editable editable-click inline-input' style=''></a>"
    editField = ".#{modalId}-list .adder"
    $(editField).append(editable)
    editFieldSelector = '#' + uid
    rfChange.initeditable(editFieldSelector, modalId)
    $(editFieldSelector).editable "toggle"
    $(this).hide()

rfChange.initeditable = (selector, resourceName) ->
  $(selector).editable
    type: "text"
    mode: "inline"
    url: "/#{resourceName}/add"
    placement: "top"
    value: ""
    success: (response, newValue) ->
      rfChange.success(selector, newValue)
    error: (err) ->
      console.log "#{err}"

rfChange.success = (selector, newValue) ->
  newData = "<li class='new'>#{newValue}</li>"
  $(selector).parent().append(newData)
  $(selector).remove()

rfChange.bsfire = ->
  modals = ['impact', 'status', 'system', 'change_type', 'priority']
  for modalName in modals
    modalSelector = "##{modalName}Modal"
    $(modalSelector).on "show.bs.modal", ->
      rfChange.handleAdd(modalName)

rfChange.overCount = ->
  $("#title_label").parent().removeClass('has-success')
  $("#title_label").parent().addClass("has-error")

rfChange.underCount = ->
  $("#title_label").parent().removeClass('has-error')
  $("#title_label").parent().addClass('has-success')
  setTimeout (->
    rfChange.removeParentClass('has-success','#title_label')
  ), 1200

rfChange.removeParentClass = (className,selector) ->
  $(selector).parent().removeClass(className)

rfChange.replaceInput = (modalName) ->
  $.getJSON "/#{modalName}/list", (newValues) ->
    wrapperName = "#{modalName}-wrapper"
    randomId = Math.floor(Math.random() * 1000001)
    dataJs = []
    for value in newValues
      v = {id: value, text: value}
      dataJs.push v
    $(".#{wrapperName}").first().replaceWith("<input id='#{randomId}' class='select optional select2 #{wrapperName}' style='width: 200px' placeholder='Select #{modalName}' name='change[modalName]'>");
    $("##{randomId}").select2({width: 'element', data: dataJs})
    $("##{randomId}").select2('val', newValues[newValues.length - 1])