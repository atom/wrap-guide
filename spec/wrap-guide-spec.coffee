{EditorView, WorkspaceView} = require 'atom'

describe "WrapGuide", ->
  [editorView, wrapGuide] = []

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    atom.workspaceView.openSync('sample.js')

    waitsForPromise ->
      atom.packages.activatePackage('wrap-guide')

    runs ->
      atom.workspaceView.attachToDom()
      atom.workspaceView.height(200)
      atom.workspaceView.width(1500)
      editorView = atom.workspaceView.getActiveView()
      wrapGuide = atom.workspaceView.find('.wrap-guide').view()
      editorView.trigger 'resize'

  describe "@initialize", ->
    it "appends a wrap guide to all existing and new editor", ->
      expect(atom.workspaceView.panes.find('.pane').length).toBe 1
      expect(atom.workspaceView.panes.find('.underlayer > .wrap-guide').length).toBe 1
      editorView.splitRight()
      expect(atom.workspaceView.find('.pane').length).toBe 2
      expect(atom.workspaceView.panes.find('.underlayer > .wrap-guide').length).toBe 2

  describe "@updateGuide", ->
    it "positions the guide at the configured column", ->
      width = editorView.charWidth * wrapGuide.getDefaultColumn()
      expect(width).toBeGreaterThan(0)
      expect(wrapGuide.position().left).toBe(width)
      expect(wrapGuide).toBeVisible()

  describe "when the font size changes", ->
    it "updates the wrap guide position", ->
      initial = wrapGuide.position().left
      expect(initial).toBeGreaterThan(0)
      fontSize = atom.config.get("editor.fontSize")
      atom.config.set("editor.fontSize", fontSize + 10)
      expect(wrapGuide.position().left).toBeGreaterThan(initial)
      expect(wrapGuide).toBeVisible()

  describe "using a custom config column", ->
    it "places the wrap guide at the custom column", ->
      atom.config.set('wrap-guide.columns', [{pattern: '\.js$', column: 20}])
      wrapGuide.updateGuide()
      width = editorView.charWidth * 20
      expect(width).toBeGreaterThan(0)
      expect(wrapGuide.position().left).toBe(width)

    it "uses the default column when no custom column matches the path", ->
      atom.config.set('wrap-guide.columns', [{pattern: '\.jsp$', column: '100'}])
      wrapGuide.updateGuide()
      width = editorView.charWidth * wrapGuide.getDefaultColumn()
      expect(width).toBeGreaterThan(0)
      expect(wrapGuide.position().left).toBe(width)

    it "hides the guide when the config column is less than 1", ->
      atom.config.set('wrap-guide.columns', [{pattern: 'sample\.js$', column: -1}])
      wrapGuide.updateGuide()
      expect(wrapGuide).toBeHidden()

    it "ignores invalid regexes", ->
      atom.config.set('wrap-guide.columns', [{pattern: '(', column: -1}])
      expect(-> wrapGuide.updateGuide()).not.toThrow()

  describe "when no lines exceed the guide column and the editor width is smaller than the guide column position", ->
    it "hides the guide", ->
      atom.workspaceView.width(10)
      editorView.resize()
      wrapGuide.updateGuide()
      expect(wrapGuide).toBeHidden()

  it "only attaches to editorViews that are part of a pane", ->
    editorView2 = new EditorView(mini: true)
    editorView.overlayer.append(editorView2)
    expect(editorView2.find('.wrap-guide').length).toBe 0
