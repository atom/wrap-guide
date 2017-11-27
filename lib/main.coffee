{CompositeDisposable} = require 'atom'
WrapGuideElement = require './wrap-guide-element'

module.exports =
  config:
    enabled:
      type: 'boolean'
      default: true

  activate: ->
    atom.workspace.observeTextEditors (editor) ->
      editorElement = atom.views.getView(editor)
      wrapGuideElement = new WrapGuideElement(editor, editorElement)

    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'wrap-guide:toggle': => @toggle()

  deactivate: ->
    @subscriptions.dispose()

  toggle: ->
    currentState = atom.config.get('wrap-guide.enabled')
    atom.config.set('wrap-guide.enabled', not currentState)
