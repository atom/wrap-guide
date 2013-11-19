{Subscriber} = require 'emissary'

module.exports =
class WrapGuide
  Subscriber.includeInto(this)

  position: 0
  visible: false

  constructor: (@editor) ->
    @subscribe atom.config.observe 'editor.fontSize', => @updateGuide()
    @subscribe @editor, 'editor:path-changed editor:min-width-changed', => @updateGuide()
    @subscribe @editor, 'editor:will-be-removed', => @unsubscribe()

    @updateGuide()

  getDefaultColumn: ->
    atom.config.getPositiveInt('editor.preferredLineLength', 80)

  getGuideColumn: (path) ->
    customColumns = atom.config.get('wrapGuide.columns')

    for customColumn in customColumns ? []
      {pattern, column} = customColumn ? {}
      pathMatches = new RegExp(pattern).test(path)
      return parseInt(column) if pathMatches

    @getDefaultColumn()

  updateGuide: ->
    column = @getGuideColumn(@editor.getPath())
    visible = false

    if column > 0
      position = @editor.charWidth * column
      if position < @editor.layerMinWidth or position < @editor.width()
        @position = position
        visible = position > 0

    @visible = visible
