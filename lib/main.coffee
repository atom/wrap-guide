WrapGuide = require './wrap-guide'
WrapGuideView = require './wrap-guide-view'

module.exports =
  activate: ->
    rootView.eachEditor (editor) ->
      if editor.attached and editor.getPane()
        new WrapGuideView(new WrapGuide(editor), editor.underlayer)

  deactivate: ->
    # TODO: Remove subscription created in activate
