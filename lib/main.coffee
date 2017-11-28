WrapGuideElement = require './wrap-guide-element'

module.exports =
  activate: ->
    watchedEditors = new WeakSet()

    atom.workspace.observeTextEditors (editor) ->
      return if watchedEditors.has(editor)

      editorElement = atom.views.getView(editor)
      wrapGuideElement = new WrapGuideElement(editor, editorElement)

      watchedEditors.add(editor)
      editor.onDidDestroy -> watchedEditors.delete(editor)
