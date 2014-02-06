{_, $, View} = require 'atom'

module.exports =
class WrapGuideView extends View
  @activate: ->
    atom.workspaceView.eachEditorView (editorView) ->
      if editorView.attached and editorView.getPane()
        editorView.underlayer.append(new WrapGuideView(editorView))

  @content: ->
    @div class: 'wrap-guide'

  initialize: (@editorView) ->
    @subscribe atom.config.observe 'editor.fontSize', => @updateGuide()
    @subscribe @editorView, 'editor:path-changed', => @updateGuide()
    @subscribe @editorView, 'editor:min-width-changed', => @updateGuide()
    @subscribe $(window), 'resize', => @updateGuide()

  getDefaultColumn: ->
    atom.config.getPositiveInt('editor.preferredLineLength', 80)

  getGuideColumn: (path) ->
    customColumns = atom.config.get('wrap-guide.columns')
    return @getDefaultColumn() unless _.isArray(customColumns)
    for customColumn in customColumns when _.isObject(customColumn)
      {pattern, column} = customColumn
      return parseInt(column) if pattern and new RegExp(pattern).test(path)
    @getDefaultColumn()

  updateGuide: ->
    column = @getGuideColumn(@editorView.getEditor().getPath())
    if column > 0
      columnWidth = @editorView.charWidth * column
      if columnWidth < @editorView.layerMinWidth or columnWidth < @editorView.width()
        @css('left', columnWidth).show()
      else
        @hide()
    else
      @hide()
