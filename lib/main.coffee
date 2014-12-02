WrapGuideElement = require './wrap-guide-element'

module.exports =
  activate: ->
    atom.workspace.observeTextEditors (editor) ->
      wrapGuideElement = new WrapGuideElement().initialize(editor)
      editorElement = atom.views.getView(editor)
      editorElement.querySelector(".underlayer")?.appendChild(wrapGuideElement)
