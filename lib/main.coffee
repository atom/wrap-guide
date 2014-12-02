WrapGuideElement = require './wrap-guide-element'

module.exports =
  activate: ->
    atom.workspaceView.eachEditorView (editorView) =>
      if editorView.attached and editorView.getPane()
        wrapGuideElement = new WrapGuideElement().initialize(editorView.getModel())
        editorView.underlayer.element.appendChild(wrapGuideElement)

  deactivate: ->
