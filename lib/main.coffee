WrapGuideElement = require './wrap-guide-element'

module.exports =
  activate: ->
    atom.workspace.observeTextEditors (editor) ->
      editorElement = atom.views.getView(editor)
      wrapGuideElement = new WrapGuideElement(editor, editorElement)
