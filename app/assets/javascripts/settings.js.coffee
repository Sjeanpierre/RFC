$(document).ready ->
  rfChange.openModalOnButtonClick('.add-sys-item', '.system-item-modal')
  rfChange.openModalOnButtonClick('.add-system-link', '.system-modal')
  rfChange.bindNewItemButton()
  rfChange.applyActiveClass()
  rfChange.bindAddItemButton()
  rfChange.bindSaveSystemButton()


rfChange.openModalOnButtonClick = (button_selector, modal_selector) ->
  $("#{button_selector}").click ->
    $("#{modal_selector}").modal('show')


#System list stacked tabs
rfChange.applyActiveClass = ->
  $('.category-list li:first').addClass('active')
  $('.system-list div:first').addClass('active')

#Handling the adding of new system items
rfChange.bindNewItemButton = ->
  $('.add-sys-item').click (clickevent) ->
    category_name = $(clickevent.currentTarget).data('category')
    $('#item-modal-title').text("Add New Item To #{category_name} Category")

rfChange.bindAddItemButton = ->
  $('#add-item-button').click ->
    system_name = $('#sys-input-field').val()
    system_category = $('.category-list li.active').data('category')
    rfChange.submitNewSystem(system_category, system_name)
    $('#sys-input-field').val('')

rfChange.bindSaveSystemButton = ->
  $('#save-system-button').click ->
    system_name = $('#system-name-field').val()
    system_category = $('#system-category-field').val()
    rfChange.submitNewSystem(system_category, system_name)
    $('#system-name-field').val('')
    $('#system-category-field').val('')
    rfChange.reloadSystemNames()

rfChange.submitNewSystem = (system_category, system_name) ->
  $.ajax
    url: "/system/add"
    type: 'POST'
    dataType: 'json'
    data: {"system_category": system_category, "system_name": system_name}
    success: ->
      rfChange.callMessenger("'#{system_name}' was added to the #{system_category} category", 'success')
      rfChange.updateSystemNameList(system_name)
    error: (data, status, response) ->
      error_message = data.responseJSON.error
      rfChange.callMessenger(error_message, 'error')

rfChange.reloadSystemNames = ->
  $.ajax
    url: "/change/settings/render/system_names"
    type: 'get'
    dataType: 'html'
    success: (data, status, response) ->
      rfChange.replaceContent('#system_names', data)
      rfChange.applyActiveClass()
    error: (data, status, response) ->
      console.log(data)


rfChange.updateSystemNameList = (NewItemName) ->
  category_name = $('.category-list li.active').data('category')
  ul_container = $("#tab_#{category_name}")
  ul_container.children('ul').append("<li>#{NewItemName.toUpperCase()}</li>")


