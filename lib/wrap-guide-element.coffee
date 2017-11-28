{CompositeDisposable} = require 'atom'

module.exports =
class WrapGuideElement
  constructor: (@editor, @editorElement) ->
    @subscriptions = new CompositeDisposable()
    @configSubscriptions = new CompositeDisposable()
    @element = document.createElement('div')
    @element.setAttribute('is', 'wrap-guide')
    @element.classList.add('wrap-guide')
    @attachToLines()
    @handleEvents()
    @updateGuide()

    @element.updateGuide = @updateGuide.bind(this)
    @element.getDefaultColumn = @getDefaultColumn.bind(this)

  attachToLines: ->
    scrollView = @editorElement.querySelector('.scroll-view')
    scrollView?.appendChild(@element)

  handleEvents: ->
    updateGuideCallback = => @updateGuide()

    @handleConfigEvents()

    @subscriptions.add atom.config.onDidChange 'editor.fontSize', =>
      # TODO: Use async/await once this file is converted to JS
      @editorElement.getComponent().getNextUpdatePromise().then -> updateGuideCallback()

    @subscriptions.add @editorElement.onDidChangeScrollLeft(updateGuideCallback)
    @subscriptions.add @editor.onDidChangePath(updateGuideCallback)
    @subscriptions.add @editor.onDidChangeGrammar =>
      @configSubscriptions.dispose()
      @handleConfigEvents()
      updateGuideCallback()

    @subscriptions.add @editor.onDidDestroy =>
      @subscriptions.dispose()
      @configSubscriptions.dispose()

    @subscriptions.add @editorElement.onDidAttach =>
      @attachToLines()
      updateGuideCallback()

  handleConfigEvents: ->
    updateGuideCallback = => @updateGuide()
    @configSubscriptions.add atom.config.onDidChange(
      'editor.preferredLineLength',
      scope: @editor.getRootScopeDescriptor(),
      updateGuideCallback
    )
    @configSubscriptions.add atom.config.onDidChange(
      'wrap-guide.enabled',
      scope: @editor.getRootScopeDescriptor(),
      updateGuideCallback
    )

  getDefaultColumn: ->
    atom.config.get('editor.preferredLineLength', scope: @editor.getRootScopeDescriptor())

  isEnabled: ->
    atom.config.get('wrap-guide.enabled', scope: @editor.getRootScopeDescriptor()) ? true

  updateGuide: ->
    column = @getDefaultColumn()
    if column > 0 and @isEnabled()
      columnWidth = @editorElement.getDefaultCharacterWidth() * column
      columnWidth -= @editorElement.getScrollLeft()
      @element.style.left = "#{Math.round(columnWidth)}px"
      @element.style.display = 'block'
    else
      @element.style.display = 'none'

  destroy: ->
    @element.remove()
    @subscriptions.dispose()
    @configSubscriptions.dispose()
