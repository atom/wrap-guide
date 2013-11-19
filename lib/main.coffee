WrapGuide = require './wrap-guide'
WrapGuideView = require './wrap-guide-view'

module.exports =
  activate: ->
    rootView.eachEditor (editor) ->
      if editor.attached and editor.getPane()
        model = new WrapGuide(editor)
        new WrapGuideView(model, editor.underlayer[0])

  deactivate: ->
    # TODO: Remove subscription created in activate
