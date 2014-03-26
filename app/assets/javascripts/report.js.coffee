Array::unique = ->
  output = {}
  output[@[key]] = @[key] for key in [0...@length]
  value for key, value of output

$(document).ready ->
  $('#mixable').mixItUp()
  rfChange.initMultiSelect()
  rfChange.bindSelectButtons()

rfChange.initMultiSelect = ->
  $('.multiselect').multiselect
      includeSelectAllOption: true
      enableCaseInsensitiveFiltering: true
      onChange: () ->
        rfChange.handleMultiSelectChanges()

rfChange.handleMultiSelectChanges = () ->
  searchIDs = []
  $(".mixer-buttons input:checkbox:checked").map ->
    if $(this).val() != 'multiselect-all'
      searchIDs.push $(this).val()
  if searchIDs.length
    grouped_filters = rfChange.groupings(searchIDs)
    filter = rfChange.product(grouped_filters).join()
  else
    filter = 'all'
  console.log(filter)
  $('#mixable').mixItUp('filter',filter)


rfChange.product = (sets) ->
  result = [[]]
  while sets.length != 0
    t = result
    result = []
    b = sets.shift()
    for a in t
      for n in b
        result.push(a + [n])
  return result

rfChange.groupings = (list) ->
  groups = []
  listTypes = list.map (listItem) ->
    listItem.split('-')[0].slice(1)
  uniqueTypes = listTypes.unique()
  itemGroups = {}
  for item in uniqueTypes
    itemGroups[item] = []
  for item,index in list
    itemGroups[listTypes[index]].push(item)
  for keys in uniqueTypes
    groups.push(itemGroups[keys])
  return groups

rfChange.bindSelectButtons = ->
  $('.selectable').click ->
    element = $(this)
    parentDiv = $(this).closest('.mix')
    if element.hasClass('selected')
      element.removeClass('selected')
      parentDiv.removeClass('selected-1')
    else
      element.addClass('selected')
      parentDiv.addClass('selected-1')

