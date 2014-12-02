class WrapGuideElement extends HTMLDivElement
  initialize: (@editor) ->
    @classList.add('wrap-guide')
    @handleEvents()
    @updateGuide()
    this

  handleEvents: ->
    updateGuideCallback = => @updateGuide()

    subscriptions = []
    subscriptions.push atom.config.onDidChange('editor.preferredLineLength', updateGuideCallback)
    subscriptions.push atom.config.onDidChange('wrap-guide.columns', updateGuideCallback)
    subscriptions.push atom.config.onDidChange 'editor.fontSize', =>
      # setTimeout because we need to wait for the editor measurement to happen
      setTimeout(updateGuideCallback, 0)

    subscriptions.push @editor.onDidChangePath(updateGuideCallback)
    subscriptions.push @editor.onDidChangeGrammar(updateGuideCallback)
    subscriptions.push @editor.onDidDestroy =>
      while subscription = subscriptions.pop()
        subscription.off()

  getDefaultColumn: ->
    atom.config.get('editor.preferredLineLength')

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

module.exports =
document.registerElement('wrap-guide',
  extends: 'div'
  prototype: WrapGuideElement.prototype,
)