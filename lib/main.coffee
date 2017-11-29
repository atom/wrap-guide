{CompositeDisposable} = require 'atom'
WrapGuideElement = require './wrap-guide-element'

module.exports =
  activate: ->
    @subscriptions = new CompositeDisposable()
    @wrapGuides = new Map()

    @subscriptions.add atom.workspace.observeTextEditors (editor) =>
      return if @wrapGuides.has(editor)

      wrapGuideElement = new WrapGuideElement(editor)

      @wrapGuides.set(editor, wrapGuideElement)
      @subscriptions.add editor.onDidDestroy => @wrapGuides.delete(editor)

  deactivate: ->
    @subscriptions.dispose()
    @wrapGuides.forEach (wrapGuide, editor) -> wrapGuide.destroy()
    @wrapGuides.clear()
