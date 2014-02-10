# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
window.rfChange = {};

MODAL_NAMES = {'priority-adder': 'priority', 'status-adder': 'status', 'system-adder': 'system', 'change-type-adder': 'changeType', 'impact-adder': 'impact'}
COLOR_CLASSES = ['blue', 'green', 'purple', 'yellow', 'red']
COLOR_VALUES = ['#0099CC','#9933CC','#669900','#FF8800','#CC0000']
Messenger.options = {
  extraClasses: 'messenger-fixed messenger-on-bottom messenger-on-right',
  theme: 'flat'
}

$(document).ready ->
  $('.change-form').parsley()
  $('#change-form').submit (event) ->
    rfChange.updateTextarea()
    rfChange.validateForm(event)
  $('.select2').select2()
  $('.approver-select').select2()
  $('#priority-adder, #status-adder, #system-adder, #change-type-adder, #impact-adder').click (clickevent) ->
    rfChange.modalhandler(clickevent)
  $('tbody tr[data-href]').addClass('clickable-row').click (clickevent) ->
    rfChange.rowClick(clickevent)
  $('.approver-select').on 'change', (changeevent) ->
    rfChange.colorSet(changeevent)
  rfChange.titleCounter()
  rfChange.setInitialFormDate()
  rfChange.bindApproval()
  rfChange.bindDatatable()
  rfChange.setApproverColors()
  rfChange.processTimeline()
  rfChange.applyStatus()
  rfChange.donuts()
  $('#change-date').click (event) ->
    rfChange.initPickadate()
    event.stopPropagation()

$(document).on "click", ".editable-cancel, .editable-submit", ->
  $(".add").show()

$(document).on "click", ".editable-cancel", ->
  $('.adder a').last().remove()

rfChange.rowClick = (clickevent) ->
  window.location = $(clickevent.currentTarget).attr('data-href')


rfChange.processTimeline = ->
  $('div.timeline-container ul.timeline li:odd').addClass('timeline-inverted')
  $('ul.timeline div.timeline-badge').each ->
    event_type = $(this).data('etype')
    rfChange.applyGraphics(event_type,$(this))


rfChange.applyGraphics = (event_type,object) ->
  if event_type == 'Created'
    object.addClass('info')
    object.children('i').addClass('glyphicon-edit')
  else if event_type == 'Approved'
    object.addClass('success')
    object.children('i').addClass('glyphicon-thumbs-up')
  else if event_type == 'Rejected'
    object.addClass('danger')
    object.children('i').addClass('glyphicon-thumbs-down')
  else if event_type == 'Completed'
    object.addClass('success')
    object.children('i').addClass('glyphicon-check')





rfChange.validateForm = (event) ->
  if $('#change-form').parsley('validate')
#    $('#change-form').submit()
  else
    rfChange.errorNotification()
    event.preventDefault()

rfChange.updateTextarea = ->
  rollbackContent = tinyMCE.get('rollback-textarea').getContent()
  summaryContent = tinyMCE.get('summary-textarea').getContent()
  $('#rollback-textarea').val(rollbackContent)
  $('#summary-textarea').val(summaryContent)


rfChange.bindApproval = ->
  $('#approve, #reject').click (clickevent) ->
    $('.btn-success, .btn-danger').addClass('disabled')
    if clickevent.currentTarget.attributes.id.value == 'approve'
      rfChange.handleApprove($(this).data('cid'))
    else
      rfChange.handleReject($(this).data('cid'))

rfChange.errorNotification = ->
  contents = $('.error-notification .parsley-error-list li')
  contents.each ->
    errorMsg = $(this).html()
    rfChange.callMessenger(errorMsg, 'error')

rfChange.callMessenger = (text, type) ->
  Messenger().post
    message: text
    type: type
    showCloseButton: true


rfChange.bindDatatable = ->
  $("#dtable").dataTable
    aaSorting: [
      [0, "asc"]
    ]
    aoColumnDefs: [
      bSearchable: false
      aTargets: [4]
    ]
    sDom: "<'row'<'span6'l><'span6'f>r>t<'row'<'span6'i><'span6'p>>"
    sFilterInput: "form-control input-sm form-control 3784057"
    sPaginationType: "bootstrap"
    bRetrieve: true
    oLanguage:
      sLengthMenu: "_MENU_ records per page"
      sSearch: ""
      sLengthMenu: "_MENU_ <div class='length-text'>records per page</div>"
    fnPreDrawCallback: ->
      $(".dataTables_filter input").addClass "form-control input-sm"
      $(".dataTables_filter input").css "width", "200px"
      $(".dataTables_length select").addClass "form-control input-sm"
      $(".dataTables_length select").css "width", "75px"
      $('.dataTables_filter input').attr('placeholder', 'Search');


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


rfChange.colorSet = (changed) ->
  if typeof changed.added != 'undefined'
    newItem = $('.select2-choices .select2-search-choice').last()
    randomElement = rfChange.getRandomColor()
    newItem.attr('id', "#{randomElement}")

rfChange.setApproverColors = ->
  approvers = $('.approver-list li.approver .label')
  randomElement = rfChange.getRandomColor(true)
  approvers.each ->
    $(this).css('background-color', "#{randomElement}")


rfChange.getRandomColor = (raw=false) ->
  if raw
    COLOR_VALUES[Math.floor(Math.random() * COLOR_VALUES.length)]
  else
    COLOR_CLASSES[Math.floor(Math.random() * COLOR_CLASSES.length)]


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

rfChange.donuts = ->
  if document.title == 'Dashboard'
    donuts = ['status', 'priority', 'system', 'creator']
    for donut in donuts
      rfChange.morrisCounts(donut, donut)



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
    rfChange.removeParentClass('has-success', '#title_label')
  ), 1200

rfChange.removeParentClass = (className, selector) ->
  $(selector).parent().removeClass(className)

rfChange.setDate = (event) ->
  $('#change-date').text($('#change-date-input').val())

rfChange.setInitialFormDate = ->
  $('#change-date-input').val($('#change-date').text())

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

rfChange.handleApprove = (changeId) ->
  $.ajax
    url: "/change/approve/#{changeId}"
    type: 'POST'
    success: (data, status, response) ->
      $('div.change-heading').data('cstatus', 'approved')
      $('.approval-buttons').replaceWith('<h2><p class="text-center text-success">Change Approved!</p></h2>')
      rfChange.applyStatus()
      error: (data, status, response) ->
        console.log(data)


rfChange.handleReject = (changeId) ->
  $.ajax
    url: "/change/reject/#{changeId}"
    type: 'POST'
    success: (data, status, response) ->
      $('div.change-heading').data('cstatus', 'rejected')
      $('.approval-buttons').replaceWith('<h2><p class="text-center text-danger">Change Rejected!</p></h2>')
      rfChange.applyStatus()
      error: (data, status, response) ->
        console.log(data)

rfChange.applyStatus = ->
  status = $('div.change-heading').data('cstatus')
  bad = 'label label-danger glyphicon glyphicon-thumbs-down'
  good = 'label label-success glyphicon glyphicon-thumbs-up'
  if status  in ['completed', 'approved']
    classes = good
  else if status in ['rejected', 'aborted']
    classes = bad
  else
    classes = ''
  $('div.change-heading h2 span.status').addClass(classes)


rfChange.initPickadate = ->
  affected_input = $('#change-date-input').pickadate(
    clear: ''
    min: true
    format: 'mm/dd/yyyy'
    onSet: (event) ->
      rfChange.setDate(event)
  )
  picker_open_close = affected_input.pickadate('picker')
  picker_open_close.open()
  $('#change-date-input').attr('type', 'hidden')

rfChange.morrisDonut = (data, element) ->
  Morris.Donut
    element: "#{element}"
    data: data,
    colors: COLOR_VALUES #['#0BA462', '#3752B7', '#EF1313', '#EF6909']


rfChange.morrisCounts = (resource, element) ->
  $.ajax
    url: "/#{resource}/count"
    type: 'get'
    success: (data, status, response) ->
      rfChange.morrisDonut(response.responseJSON, element)
      error: (data, status, response) ->
        console.log(data)
