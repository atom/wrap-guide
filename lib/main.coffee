{CompositeDisposable} = require 'atom'
WrapGuideElement = require './wrap-guide-element'

module.exports =
  activate: ->
    watchedEditors = new WeakSet()
    @subscriptions = new CompositeDisposable()

    @subscriptions.add atom.workspace.observeTextEditors (editor) ->
      return if watchedEditors.has(editor)

      editorElement = atom.views.getView(editor)
      wrapGuideElement = new WrapGuideElement(editor, editorElement)

      watchedEditors.add(editor)
      @subscriptions.add editor.onDidDestroy -> watchedEditors.delete(editor)

  deactivate: ->
    @subscriptions.dispose()
