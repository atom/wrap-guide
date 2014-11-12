module.exports =
class WrapGuideView extends HTMLElement
  @activate: ->
    atom.workspaceView.eachEditorView (editorView) =>
      @create(editorView) if editorView.attached and editorView.getPane()

  @create: (editorView) ->
    wrapGuideElement = new WrapGuideElement()
    wrapGuideElement.initialize(editorView.getModel())
    editorView.underlayer.element.appendChild(wrapGuideElement)

  initialize: (@editor) ->
    @classList.add('wrap-guide')

    @handleEvents()
    @updateGuide()

  handleEvents: ->
    updateGuideCallback = => @updateGuide()

    subscriptions = []
    subscriptions.push atom.config.onDidChange('editor.preferredLineLength', updateGuideCallback)
    subscriptions.push atom.config.onDidChange('wrap-guide.columns', updateGuideCallback)
    subscriptions.push atom.config.onDidChange 'editor.fontSize', =>
      # setTimeout because we need to wait for the editor measurement to happen
      setTimeout =>
        @updateGuide()
      , 0

    subscriptions.push @editor.onDidChangePath(updateGuideCallback)
    subscriptions.push @editor.onDidChangeGrammar(updateGuideCallback)
    subscriptions.push @editor.onDidDestroy =>
      while subscription = subscriptions.pop()
        subscription.off()

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

  updateGuide: ->
    column = @getGuideColumn(@editor.getPath(), @editor.getGrammar().scopeName)
    if column > 0
      columnWidth = @editor.getDefaultCharWidth() * column
      @style.left = "#{columnWidth}px"
      @style.display = 'block'
    else
      @style.display = 'none'

WrapGuideElement = document.registerElement('wrap-guide', prototype: WrapGuideView.prototype, extends: 'div')
