Array::unique = ->
  output = {}
  output[@[key]] = @[key] for key in [0...@length]
  value for key, value of output

$(document).ready ->
  $('#mixable').mixItUp(callbacks:
    onMixEnd: () ->
      rfChange.countFiltered()
  )
  rfChange.initMultiSelect()
  rfChange.bindSelectButtons()
  rfChange.bindSelectControl()
  rfChange.countUpdater()
  rfChange.initDateRangeFilter()
  $('#panel-toggler').bigSlide()

rfChange.initMultiSelect = ->
  $('.multiselect').multiselect
    includeSelectAllOption: true
    enableCaseInsensitiveFiltering: true
    onChange: () ->
      rfChange.handleMultiSelectChanges()

rfChange.buildFilterWithDate = (targets,activeFilters) ->
  min = $('#reportrange').data('startdate')
  max = $('#reportrange').data('enddate')
  if activeFilters == 'all'
    targets.filter ->
      date = $(this).attr("data-date")
      (date >= min) and (date <= max)
  else
    targets.filter ->
      date = $(this).attr("data-date")
      (date >= min) and (date <= max) and $(this).is(activeFilters)

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
  filterObject = rfChange.buildFilterWithDate($('#mixable').mixItUp('getState').$targets,filter)
  $('#mixable').mixItUp('filter', filterObject)


rfChange.product = (sets) ->
  result = [
    []
  ]
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

rfChange.bindSelectControl = ->
  $('.select-control .selectable').click ->
    element = $(this)
    if element.hasClass('selected')
      element.removeClass('selected')
      $('.item-select .selectable').removeClass('selected')
    else
      element.addClass('selected')
      $('.item-select .selectable').filter(':visible').addClass('selected')

rfChange.bindSelectButtons = ->
  $('.item-select .selectable').click ->
    element = $(this)
    parentDiv = $(this).closest('.mix')
    if element.hasClass('selected')
      element.removeClass('selected')
      parentDiv.removeClass('selected-1')
    else
      element.addClass('selected')
      parentDiv.addClass('selected-1')

rfChange.countFiltered = ->
  filtered = $('.mix').filter(':visible').length
  $('.displayed-count #count-displayed').text(filtered)

rfChange.countUpdater = ->
  $('.selectable').click ->
    newCount = $('.item-select .selected').length
    $('.selected-count #count-selected').text(newCount)

rfChange.initDateRangeFilter = ->
  $('#reportrange').data('startdate',"10001230")
  $('#reportrange').data('enddate',"99991230")
  $("#reportrange").daterangepicker
    ranges:
      All: [
        moment('1000-12-30')
        moment('9999-12-30')
      ]
      Today: [
        moment()
        moment()
      ]
      Yesterday: [
        moment().subtract("days", 1)
        moment().subtract("days", 1)
      ]
      "Last 7 Days": [
        moment().subtract("days", 6)
        moment()
      ]
      "Last 30 Days": [
        moment().subtract("days", 29)
        moment()
      ]
      "This Month": [
        moment().startOf("month")
        moment().endOf("month")
      ]
      "Last Month": [
        moment().subtract("month", 1).startOf("month")
        moment().subtract("month", 1).endOf("month")
      ]
      "This Year": [
        moment().startOf("year")
        moment()
      ]
    showDropdowns: true
    minDate: moment('2014-01-01')
    maxDate: moment()
    (start, end) ->
      if end.year() - start.year() == 8999
        $("#reportrange span").html('All')
      else
        $("#reportrange span").html start.format("MMMM D, YYYY") + " - " + end.format("MMMM D, YYYY")
      $('#reportrange').data('startdate',start.format("YYYYMMDD"))
      $('#reportrange').data('enddate',end.format("YYYYMMDD"))
      rfChange.handleMultiSelectChanges()
