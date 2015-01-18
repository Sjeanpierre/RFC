# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
window.rfChange = {};

MODAL_NAMES = {'priority-adder': 'priority', 'status-adder': 'status', 'system-adder': 'system', 'change-type-adder': 'changeType', 'impact-adder': 'impact'}
COLOR_CLASSES = ['blue', 'green', 'purple', 'yellow', 'red']
COLOR_VALUES = ['#0099CC', '#9933CC', '#669900', '#FF8800', '#CC0000']
EDIT_BUTTONS = '<div class="text-area-edit-actions">
	        <button id="cancel-edit" type="button" class="btn btn-danger btn-sm">Cancel</button>
	        <button id="update-edit" type="button" class="btn btn-success btn-sm">Update</button>
	      </div>'
Messenger.options = {
  extraClasses: 'messenger-fixed messenger-on-bottom messenger-on-right',
  theme: 'flat'
}

$(document).ready ->
  rfChange.bindFormSubmit()
  $('.approver-select').select2()
  $('tbody tr[data-href]').addClass('clickable-row').click (clickevent) ->
    rfChange.rowClick(clickevent)
  $('.approver-select').on 'change', (changeevent) ->
    rfChange.colorSet(changeevent)
  rfChange.titleCounter()
  rfChange.setInitialFormDate()
  rfChange.bindApproval()
  rfChange.bindDatatable()
  rfChange.bindCommentModalClose()
  rfChange.prepLabelColors()
  rfChange.processTimeline()
  rfChange.processComments()
  rfChange.bindCommentButton()
  rfChange.bindUpload()
  rfChange.bindEditableUpdater()
  rfChange.initEditableUpdater('.updatable', 'duedate')
  rfChange.bindTextAreaUpdater()
  rfChange.bindTitleUpdater()
  rfChange.applyStatus()
  rfChange.donuts()
  rfChange.bindDownloadButton()
  rfChange.getSelect2Items('.select2-dropdown')
  $('#change-date').click (event) ->
    rfChange.initPickadate()
    event.stopPropagation()

$(document).on "click", ".editable-cancel, .editable-submit", ->
  $(".add").show()


$(document).on "click", ".editable-cancel", ->
  $('.adder a').last().remove()

rfChange.rowClick = (clickevent) ->
  window.location = $(clickevent.currentTarget).attr('data-href')

rfChange.formatFileSize = (bytes) ->
  ''  if typeof bytes isnt "number"
  if bytes >= 1000000000
    "#{(bytes / 1000000000).toFixed(2)} GB"
  else if bytes >= 1000000
    "#{(bytes / 1000000).toFixed(2)} MB"
  else
    "#{(bytes / 1000).toFixed(2)} KB"

rfChange.bindUpload = ->
  $(document).on "drop dragover", (e) ->
    e.preventDefault()
  ul = $(".download-list-container .download-list")
  $("#add-upload-button").click ->
    $(this).parent().find("input").click()
  $("#upload").fileupload
    dropZone: $("#drop")
    add: (e, data) ->
      tpl = $('<li class="working"><div class="download-details"><input type="text" value="0" data-width="48" data-height="48" data-fgColor="#5BC0DE" data-readOnly="1" data-bgColor="#fff" /><p></p></div><span id="status-indicator" class="glyphicon glyphicon-refresh"></span></li>');
      tpl.find("p").text(data.files[0].name).append("<i>#{rfChange.formatFileSize(data.files[0].size)}</i>")
      data.context = tpl.appendTo(ul)
      tpl.find("input").knob()
      tpl.find("span").click ->
        jqXHR.abort()  if tpl.hasClass("working")
        tpl.fadeOut ->
          tpl.remove()
      jqXHR = data.submit()
    progress: (e, data) ->
      progress = parseInt(data.loaded / data.total * 100, 10)
      data.context.find("input").val(progress).change()
      rfChange.uploadComplete(data) if progress is 100
    fail: (e, data) ->
      data.context.addClass "error"

rfChange.uploadComplete = (data) ->
  data.context.removeClass "working"
  data.context.addClass 'done'
  data.context.find('#status-indicator').removeClass('glyphicon-refresh').addClass('glyphicon-ok')


rfChange.processTimeline = ->
  $('div.timeline-container ul.timeline li:odd').addClass('timeline-inverted')
  $('ul.timeline div.timeline-badge').each ->
    event_type = $(this).data('etype')
    rfChange.applyGraphics(event_type, $(this))

rfChange.toggleCommentForm = (state) ->
  if state == 'show'
    $('#new-comment-button').hide()
    $('#comment-form-container').show()
  else if state == 'hide'
    $('#comment-form-container').hide()
    $('.comment-input').val('')
    $('#new-comment-button').show()
  else
    console.log('invalid param for toggleCommentForm')


rfChange.bindCommentButton = ->
  $('#new-comment-button').click ->
    rfChange.toggleCommentForm('show')


rfChange.processComments = ->
  $('#comments-form').submit (submitEvent) ->
    changeId = $('.cdata').data('cid')
    submitEvent.preventDefault()
    rfChange.submitComments($(this), changeId)


rfChange.submitComments = (submitEvent, changeId) ->
  $.ajax
    url: "/change/#{changeId}/comment"
    type: 'POST'
    dataType: 'html'
    data: $(submitEvent).serialize()
    success: (data, status, response) ->
      rfChange.handleCommentAdd(data)
    error: (data, status, response) ->
      console.log(data)


rfChange.handleCommentAdd = (data) ->
  $('.comment-list').html(data)
  rfChange.setLabelColors($('.commenter .commenter-colors'))
  $('#comment-count').html($('.comment-item').length)
  rfChange.callMessenger('Comment Saved!', 'success')
  rfChange.toggleCommentForm('hide')

rfChange.bindCommentModalClose = ->
  $('#commentsModal').on 'hide.bs.modal', ->
    rfChange.toggleCommentForm('hide')


rfChange.applyGraphics = (event_type, object) ->
  if event_type == 'Created'
    object.addClass('info')
    object.children('i').addClass('glyphicon-flash')
  else if event_type == 'Approved'
    object.addClass('warning')
    object.children('i').addClass('glyphicon-thumbs-up')
  else if event_type == 'Rejected'
    object.addClass('danger')
    object.children('i').addClass('glyphicon-thumbs-down')
  else if event_type == 'Updated'
    object.addClass('primary')
    object.children('i').addClass('glyphicon-edit')
  else if event_type == 'Completed'
    object.addClass('success')
    object.children('i').addClass('glyphicon-check')


rfChange.validateForm = (event) ->
  if $('#change-form').parsley().validate()
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
  $('#approve, #reject, #complete').click (clickevent) ->
    $('.btn-success, .btn-danger').addClass('disabled')
    if clickevent.currentTarget.attributes.id.value == 'approve'
      rfChange.handleApprove($(this).data('cid'))
    else if clickevent.currentTarget.attributes.id.value == 'reject'
      rfChange.handleReject($(this).data('cid'))
    else if clickevent.currentTarget.attributes.id.value == 'complete'
      rfChange.handleComplete($(this).data('cid'))
    rfChange.reloadSections('change_details')
    rfChange.reloadSections('events')
    rfChange.reloadSections('change_subheading')

rfChange.afterReloadActions = (selector) ->
  if selector == '#events'
    rfChange.processTimeline()
  else if selector == '#change_details'
    rfChange.prepLabelColors()
    rfChange.bindEditableUpdater()
  else if selector == '#change_subheading'
    rfChange.applyStatus()


rfChange.reloadSections = (sectionId) ->
  $.ajax
    url: "/change/#{rfChange.changeId()}/render/#{sectionId}"
    type: 'get'
    dataType: 'html'
    success: (data, status, response) ->
      rfChange.replaceContent("##{sectionId}", data)
    error: (data, status, response) ->
      console.log(data)

rfChange.replaceContent = (selector, content) ->
  $(selector).html(content)
  rfChange.afterReloadActions(selector)


rfChange.errorNotification = ->
  contents = $('.error-notification .filled li')
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
      [0, "desc"]
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

rfChange.prepLabelColors = ->
  approvers = $('.approver-list li.approver .label')
  commenters = $('.commenter .commenter-colors')
  rfChange.setLabelColors(approvers)
  rfChange.setLabelColors(commenters)

rfChange.setLabelColors = (selector) ->
  randomElement = rfChange.getRandomColor(true)
  selector.css('background-color', "#{randomElement}")


rfChange.getRandomColor = (raw = false) ->
  if raw
    COLOR_VALUES[Math.floor(Math.random() * COLOR_VALUES.length)]
  else
    COLOR_CLASSES[Math.floor(Math.random() * COLOR_CLASSES.length)]


rfChange.success = (selector, newValue) ->
  newData = "<li class='new'>#{newValue}</li>"
  $(selector).parent().append(newData)
  $(selector).remove()

rfChange.donuts = ->
  if document.title == 'Dashboard'
    donuts = ['status', 'priority', 'system', 'creator']
    for donut in donuts
      rfChange.morrisCounts(donut, donut)


rfChange.bindFormSubmit = ->
  $('#change-form').submit (event) ->
    rfChange.updateTextarea()
    rfChange.validateForm(event)


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

rfChange.handleApprove = (changeId) ->
  $.ajax
    url: "/change/approve/#{changeId}"
    type: 'POST'
    success: (data, status, response) ->
      $('div.change-heading').data('cstatus', 'approved')
      $('.approval-buttons').replaceWith('<h2><p class="text-center text-success">Change Approved!</p></h2>')
      rfChange.callMessenger('Change Approved!', 'success')
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
      rfChange.callMessenger('Change Rejected!', 'success')
      rfChange.applyStatus()
      error: (data, status, response) ->
        console.log(data)

rfChange.handleComplete = (changeId) ->
  $.ajax
    url: "/change/complete/#{changeId}"
    type: 'POST'
    success: (data, status, response) ->
      $('div.change-heading').data('cstatus', 'completed')
      $('.post-approval').replaceWith('<h2><p class="text-center text-success">Change Marked as Completed!</p></h2>')
      rfChange.callMessenger('Change marked as Completed!', 'success')
      rfChange.applyStatus()
      error: (data, status, response) ->
        console.log(data)

rfChange.applyStatus = ->
  status = $('div.change-heading').data('cstatus')
  buttonClass = rfChange.statusButtonColor(status)
  spanClass = rfChange.statusSpanIcon(status)
  $('#status-indicator-button').addClass(buttonClass)
  $('#status-indicator-span').addClass(spanClass)


rfChange.statusButtonColor = (status) ->
  if status  in ['completed', 'approved', 'new', 'pending']
    return 'btn-success'
  else if status in ['rejected', 'aborted']
    return 'btn-danger'
  else
    return ''

rfChange.statusSpanIcon = (status) ->
  if status  in ['approved']
    return 'glyphicon-thumbs-up'
  else if status in ['new', 'pending']
    return 'glyphicon-flash'
  else if status in ['completed']
    return 'glyphicon-ok-circle'
  else if status in ['aborted']
    return 'glyphicon-ban-circle'
  else if status in ['rejected', 'aborted']
    return 'glyphicon-thumbs-down'
  else
    return ''

rfChange.bindDownloadButton = () ->
  $('.download-link').click (clickevent) ->
    clickevent.stopPropagation
    downloadRoute = $(this).data('href')
    rfChange.getDownloadLink(downloadRoute)


rfChange.getDownloadLink = (route) ->
  $.ajax
    url: route
    type: 'get'
    success: (data, status, response) ->
      console.log(data)
      document.getElementById("downloadFrame").src = response.responseJSON.url
      error: (data, status, response) ->
        console.log("there was an error retrieving the list of #{resourceName}")
        console.log(data)


rfChange.bindTextAreaUpdater = ->
  $('.edit-textarea-icon').click (clickevent) ->
    clickevent.stopPropagation()
    selectorId = $(this).closest('.change-textarea-container').find('.text-updatable').attr('id')
    rfChange.initTextAreaEditer(selectorId)

rfChange.initTextAreaEditer = (elementID) ->
  currentVal = $("##{elementID}").html()
  rfChange.localStorageHelper(elementID, currentVal)
  if tinymce.editors[elementID]?
    tinymce.editors[elementID].show()
  else
    tinymce.init
      selector: "##{elementID}"
      inline: false
      #the cake is a lie, the tinymce config is in in the config directory
  rfChange.addEditActionButtons(elementID)

rfChange.addEditActionButtons = (elementID) ->
  $("##{elementID}").parent().append(EDIT_BUTTONS)
  $('#cancel-edit').click (clickevent) ->
    rfChange.cancelTextAreaEdit(clickevent, this, elementID)
  $('#update-edit').click (clickevent) ->
    rfChange.updateTextAreaEdit(clickevent, this, elementID)

rfChange.cancelTextAreaEdit = (clickevent, context, elementId) ->
  clickevent.stopPropagation()
  $(context).closest('div').remove()
  tinymce.editors[elementId].hide()
  $("##{elementId}").html(rfChange.localStorageHelper(elementId))
  rfChange.removeLocalStorageItem(elementId)

rfChange.updateTextAreaEdit = (clickevent, context, elementId) ->
  clickevent.stopPropagation()
  $(context).closest('div').remove()
  tinymce.editors[elementId].hide()
  if $("##{elementId}").html() != rfChange.localStorageHelper(elementId)
    content = $("##{elementId}").html()
    changeID = $('.cdata').data('cid')
    rfChange.postTextArea(changeID, elementId, content)

rfChange.changeId = ->
  $('.cdata').data('cid')

rfChange.postTextArea = (changeID, elementID, content) ->
  $.ajax
    url: "/change/#{changeID}/#{elementID}/update"
    type: 'POST'
    data: {value: content}
    success: (data, status, response) ->
      rfChange.callMessenger("#{elementID} Updated!", 'success')
      error: (data, status, response) ->
        console.log(data)


rfChange.localStorageHelper = (elementID, data = null) ->
  key = "#{elementID}-preval"
  if data
    $("##{elementID}").data('localstorageid', key)
    localStorage.setItem(key, data)
  else
    localStorage.getItem(key)

rfChange.removeLocalStorageItem = (elementID) ->
  key = "#{elementID}-preval"
  localStorage.removeItem(key)


rfChange.bindEditableUpdater = ->
  $('.edit-detail-icon').click (clickevent) ->
    clickevent.stopPropagation()
    $(this).closest('li').children('p').editable('toggle')

rfChange.bindTitleUpdater = ->
  $('.edit-title-icon').click (clickevent) ->
    clickevent.stopPropagation()
    $('.editable-title').editable('toggle')


rfChange.initEditableUpdater = (selector, resourceName) ->
  $(selector).editable
    pk: 1
    success: (response, newValue) ->
      rfChange.reloadSections('events')
    error: (err) ->
      console.log "#{err}"

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

rfChange.initSelect2ForNewPage = (object, data) ->
  placeHolderText = object.data('placeholder')
  object.select2
    placeholder: placeHolderText
    data: data

rfChange.getSelect2Items = (selector) ->
  $(selector).each ->
    resourceName = $(this).data('resource')
    rfChange.getResourceItems(resourceName, $(this))

rfChange.getResourceItems = (resourceName, object) ->
  $.ajax
    url: "/#{resourceName}/items"
    type: 'get'
    success: (data, status, response) ->
      rfChange.initSelect2ForNewPage(object, data)
      response
      error: (data, status, response) ->
        console.log("there was an error retrieving the list of #{resourceName}")
        console.log(data)