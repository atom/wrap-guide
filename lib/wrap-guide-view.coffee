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
    @subscribe atom.config.observe 'editor.fontSize', callNow: false, @updateGuide
    @subscribe atom.config.observe 'editor.preferredLineLength', callNow: false, @updateGuide
    @subscribe atom.config.observe 'wrap-guide.columns', callNow: false, @updateGuide
    @subscribe @editorView.getEditor(), 'path-changed', @updateGuide
    @subscribe @editorView.getEditor(), 'grammar-changed', @updateGuide
    @subscribe $(window), 'resize', @updateGuide

    @updateGuide()

  getDefaultColumn: ->
    atom.config.getPositiveInt('editor.preferredLineLength', 80)

  getGuideColumn: (path, scopeName) ->
    customColumns = atom.config.get('wrap-guide.columns')
    return @getDefaultColumn() unless Array.isArray(customColumns)
    for customColumn in customColumns when typeof customColumn is 'object'
      {pattern, scope, column} = customColumn
      if pattern
        try
          regex = new RegExp(pattern)
        catch
          continue
        return parseInt(column) if regex.test(path)
      else if scope
        return parseInt(column) if scope is scopeName
    @getDefaultColumn()

  updateGuide: =>
    editor = @editorView.getEditor()
    column = @getGuideColumn(editor.getPath(), editor.getGrammar().scopeName)
    if column > 0
      columnWidth = @editorView.charWidth * column
      @css('left', columnWidth).show()
    else
      @hide()
