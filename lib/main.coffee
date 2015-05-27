Grim = require 'grim'

WrapGuideElement = require './wrap-guide-element'

module.exports =
  activate: ->
    @updateConfiguration()

    atom.workspace.observeTextEditors (editor) ->
      editorElement = atom.views.getView(editor)
      wrapGuideElement = new WrapGuideElement().initialize(editor, editorElement)
      editorElement.appendChild(wrapGuideElement)

  updateConfiguration: ->
    customColumns = atom.config.get('wrap-guide.columns')
    return unless customColumns

    newColumns = []
    for customColumn in customColumns when typeof customColumn is 'object'
      {pattern, scope, column} = customColumn
      if Grim.includeDeprecatedAPIs and pattern
        Grim.deprecate """
          The Wrap Guide package uses Atom's new language-specific configuration.
          Use of file name matching patterns for Wrap Guide configuration is deprecated.
          See the README for details: https://github.com/atom/wrap-guide.
        """
        newColumns.push(customColumn)
      else if scope
        if column is -1
          atom.config.set('wrap-guide.enabled', false, scopeSelector: ".#{scope}")
        else
          atom.config.set('editor.preferredLineLength', column, scopeSelector: ".#{scope}")

    newColumns = undefined if newColumns.length is 0
    atom.config.set('wrap-guide.columns', newColumns)
