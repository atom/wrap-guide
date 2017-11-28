{getLeftPosition} = require './helpers'

describe "WrapGuideElement", ->
  [editor, editorElement, wrapGuide, workspaceElement] = []

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    workspaceElement.style.height = "200px"
    workspaceElement.style.width = "1500px"

    jasmine.attachToDOM(workspaceElement)

    waitsForPromise ->
      atom.packages.activatePackage('wrap-guide')

    waitsForPromise ->
      atom.packages.activatePackage('language-javascript')

    waitsForPromise ->
      atom.packages.activatePackage('language-coffee-script')

    waitsForPromise ->
      atom.workspace.open('sample.js')

    runs ->
      editor = atom.workspace.getActiveTextEditor()
      editorElement = editor.getElement()
      wrapGuide = editorElement.querySelector(".wrap-guide")

  describe "when the font size changes", ->
    it "updates the wrap guide position", ->
      initial = getLeftPosition(wrapGuide)
      expect(initial).toBeGreaterThan(0)
      fontSize = atom.config.get("editor.fontSize")
      atom.config.set("editor.fontSize", fontSize + 10)

      waitsForPromise ->
        editorElement.getComponent().getNextUpdatePromise()

      runs ->
        expect(getLeftPosition(wrapGuide)).toBeGreaterThan(initial)
        expect(wrapGuide).toBeVisible()

    it "updates the wrap guide position for hidden editors when they become visible", ->
      initial = getLeftPosition(wrapGuide)
      expect(initial).toBeGreaterThan(0)

      waitsForPromise ->
        atom.workspace.open()

      runs ->
        fontSize = atom.config.get("editor.fontSize")
        atom.config.set("editor.fontSize", fontSize + 10)
        atom.workspace.getActivePane().activatePreviousItem()

        waitsForPromise ->
          editorElement.getComponent().getNextUpdatePromise()

        runs ->
          expect(getLeftPosition(wrapGuide)).toBeGreaterThan(initial)
          expect(wrapGuide).toBeVisible()

  describe "when the column config changes", ->
    it "updates the wrap guide position", ->
      initial = getLeftPosition(wrapGuide)
      expect(initial).toBeGreaterThan(0)
      column = atom.config.get("editor.preferredLineLength")
      atom.config.set("editor.preferredLineLength", column + 10)
      expect(getLeftPosition(wrapGuide)).toBeGreaterThan(initial)
      expect(wrapGuide).toBeVisible()

  describe "when the editor's scroll left changes", ->
    it "updates the wrap guide position to a relative position on screen", ->
      editor.setText("a long line which causes the editor to scroll")
      editorElement.style.width = "100px"

      waitsFor -> editorElement.component.getMaxScrollLeft() > 10

      runs ->
        initial = getLeftPosition(wrapGuide)
        expect(initial).toBeGreaterThan(0)
        editorElement.setScrollLeft(10)
        expect(getLeftPosition(wrapGuide)).toBe(initial - 10)
        expect(wrapGuide).toBeVisible()

  describe "when the editor's grammar changes", ->
    it "updates the wrap guide position", ->
      atom.config.set('editor.preferredLineLength', 20, scopeSelector: '.source.js')
      initial = getLeftPosition(wrapGuide)
      expect(initial).toBeGreaterThan(0)
      expect(wrapGuide).toBeVisible()

      editor.setGrammar(atom.grammars.grammarForScopeName('text.plain.null-grammar'))
      expect(getLeftPosition(wrapGuide)).toBeGreaterThan(initial)
      expect(wrapGuide).toBeVisible()

    it 'listens for preferredLineLength updates for the new grammar', ->
      editor.setGrammar(atom.grammars.grammarForScopeName('source.coffee'))
      initial = getLeftPosition(wrapGuide)
      atom.config.set('editor.preferredLineLength', 20, scopeSelector: '.source.coffee')
      expect(getLeftPosition(wrapGuide)).toBeLessThan(initial)

    it 'listens for wrap-guide.enabled updates for the new grammar', ->
      editor.setGrammar(atom.grammars.grammarForScopeName('source.coffee'))
      expect(wrapGuide).toBeVisible()
      atom.config.set('wrap-guide.enabled', false, scopeSelector: '.source.coffee')
      expect(wrapGuide).not.toBeVisible()

  describe 'scoped config', ->
    it '::getDefaultColumn returns the scope-specific column value', ->
      atom.config.set('editor.preferredLineLength', 132, scopeSelector: '.source.js')

      expect(wrapGuide.getDefaultColumn()).toBe 132

    it 'updates the guide when the scope-specific column changes', ->
      initial = getLeftPosition(wrapGuide)
      column = atom.config.get('editor.preferredLineLength', scope: editor.getRootScopeDescriptor())
      atom.config.set('editor.preferredLineLength', column + 10, scope: '.source.js')
      expect(getLeftPosition(wrapGuide)).toBeGreaterThan(initial)

    it 'updates the guide when wrap-guide.enabled is set to false', ->
      expect(wrapGuide).toBeVisible()

      atom.config.set('wrap-guide.enabled', false, scopeSelector: '.source.js')

      expect(wrapGuide).not.toBeVisible()
