ready = ->
  rfChange.openModalOnButtonClick('.add-sys-item', '.system-item-modal')
  rfChange.openModalOnButtonClick('.add-system-link', '.system-modal')
  rfChange.openModalOnButtonClick('.add-product-name', '.product-name-modal')
  rfChange.openModalOnButtonClick('.add-product-link', '.product-modal')
  rfChange.bindNewItemButton()
  rfChange.bindNewProductButton()
  rfChange.applyActiveClass()
  rfChange.bindAddItemButton()
  rfChange.bindSaveSystemButton()
  rfChange.bindAddProductButton()
  rfChange.bindSaveProductButton()


rfChange.openModalOnButtonClick = (button_selector, modal_selector) ->
  $("#{button_selector}").click ->
    $("#{modal_selector}").modal('show')


#System list stacked tabs
rfChange.applyActiveClass = ->
  $('.category-list li:first').addClass('active')
  $('.system-list div:first').addClass('active')
  $('.country-list li:first').addClass('active')
  $('.product-list div:first').addClass('active')

#Handling the adding of new system items
rfChange.bindNewItemButton = ->
  $('.add-sys-item').click (clickevent) ->
    category_name = $(clickevent.currentTarget).data('category')
    $('#item-modal-title').text("Add New Item To #{category_name} Category")

rfChange.bindNewProductButton = ->
  $('.add-product-name').click (clickevent) ->
    category_name = $(clickevent.currentTarget).data('category')
    $('#product-modal-title').text("Add New Product To #{category_name}")

rfChange.bindAddItemButton = ->
  $('#add-item-button').click ->
    system_name = $('#sys-input-field').val()
    system_category = $('.category-list li.active').data('category')
    rfChange.submitNewSystem(system_category, system_name)
    $('#sys-input-field').val('')
    rfChange.reloadSettingsArea('system_names')

rfChange.bindSaveSystemButton = ->
  $('#save-system-button').click ->
    system_name = $('#system-name-field').val()
    system_category = $('#system-category-field').val()
    rfChange.submitNewSystem(system_category, system_name)
    $('#system-name-field').val('')
    $('#system-category-field').val('')
    rfChange.reloadSettingsArea('system_names')

rfChange.bindSaveProductButton = ->
  $('#save-product-button').click ->
    console.log('detected save button for product')
    product_name = $('#product-name-input').val()
    product_country = $('#product-country-input').val()
    rfChange.submitNewProduct(product_country, product_name)
    $('#product-name-input').val('')
    $('#product-country-input').val('')
    rfChange.reloadSettingsArea('product_names')

rfChange.bindAddProductButton = ->
  $('#add-product-button').click ->
    console.log('detected add button for product')
    product_name = $('#product-name-field').val()
    product_country = $('.country-list li.active').data('category')
    rfChange.submitNewProduct(product_country, product_name)
    $('#product-name-field').val('')
    rfChange.reloadSettingsArea('product_names')

rfChange.submitNewSystem = (system_category, system_name) ->
  $.ajax
    url: "/system/add"
    type: 'POST'
    dataType: 'json'
    data: {"system_category": system_category, "system_name": system_name}
    success: ->
      rfChange.callMessenger("'#{system_name}' was added to the #{system_category} category", 'success')
    error: (data, status, response) ->
      error_message = data.responseJSON.error
      rfChange.callMessenger(error_message, 'error')

rfChange.submitNewProduct = (product_country, product_name) ->
  console.log('submitting product')
  $.ajax
    url: "/product/add"
    type: 'POST'
    dataType: 'json'
    data: {"product_country": product_country, "product_name": product_name}
    success: ->
      rfChange.callMessenger("'#{product_name}' was added to the #{product_country}", 'success')
    error: (data, status, response) ->
      error_message = data.responseJSON.error
      rfChange.callMessenger(error_message, 'error')

rfChange.reloadSettingsArea = (area_name) ->
  $.ajax
    url: "/change/settings/render/#{area_name}"
    type: 'get'
    dataType: 'html'
    success: (data, status, response) ->
      $("##{area_name}").html(data)
    error: (data, status, response) ->
      console.log(data)


$(document).ready(ready)
#$(document).on('page:load', ready)


