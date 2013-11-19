module.exports =
class WrapGuideView
  constructor: (@model, @parentView) ->
    @el = document.createElement("div")
    @el.classList.add("wrap-guide")
    @parentView.appendChild(@el)

    @model.observe 'columnPosition', ({newValue}) => @setColumnPosition(newValue)
    @model.observe 'columnVisible', ({newValue}) => @setColumnVisible(newValue)

    @setColumnVisible(@model.columnVisible)
    @setColumnPosition(@model.columnPosition)

  # Private
  setColumnVisible: (visible) ->
    @el.style.display = if visible then 'block' else 'none'

  # Private
  setColumnPosition: (positionInPx) ->
    @el.style.left = "#{positionInPx}px"
