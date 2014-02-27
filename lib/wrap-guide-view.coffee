{$, View} = require 'atom'

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
    return @getDefaultColumn() unless Array.isArray(customColumns)
    for customColumn in customColumns when typeof customColumn is 'object'
      {pattern, column} = customColumn
      continue unless pattern
      try
        regex = new RegExp(pattern)
      catch
        continue
      return parseInt(column) if regex.test(path)
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
