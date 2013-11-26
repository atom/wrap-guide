{Editor, WorkspaceView} = require 'atom'

describe "WrapGuide", ->
  [editor, wrapGuide] = []

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    atom.workspaceView.openSync('sample.js')
    atom.packages.activatePackage('wrap-guide')
    atom.workspaceView.attachToDom()
    atom.workspaceView.height(200)
    atom.workspaceView.width(1500)
    editor = atom.workspaceView.getActiveView()
    wrapGuide = atom.workspaceView.find('.wrap-guide').view()
    editor.width(editor.charWidth * wrapGuide.getDefaultColumn() * 2)
    editor.trigger 'resize'

  describe "@initialize", ->
    it "appends a wrap guide to all existing and new editors", ->
      expect(atom.workspaceView.panes.find('.pane').length).toBe 1
      expect(atom.workspaceView.panes.find('.underlayer > .wrap-guide').length).toBe 1
      editor.splitRight()
      expect(atom.workspaceView.find('.pane').length).toBe 2
      expect(atom.workspaceView.panes.find('.underlayer > .wrap-guide').length).toBe 2

  describe "@updateGuide", ->
    it "positions the guide at the configured column", ->
      width = editor.charWidth * wrapGuide.getDefaultColumn()
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
      atom.config.set('wrapGuide.columns', [{pattern: '\.js$', column: 20}])
      wrapGuide.updateGuide()
      width = editor.charWidth * 20
      expect(width).toBeGreaterThan(0)
      expect(wrapGuide.position().left).toBe(width)

    it "uses the default column when no custom column matches the path", ->
      atom.config.set('wrapGuide.columns', [{pattern: '\.jsp$', column: '100'}])
      wrapGuide.updateGuide()
      width = editor.charWidth * wrapGuide.getDefaultColumn()
      expect(width).toBeGreaterThan(0)
      expect(wrapGuide.position().left).toBe(width)

    it "hides the guide when the config column is less than 1", ->
      atom.config.set('wrapGuide.columns', [{pattern: 'sample\.js$', column: -1}])
      wrapGuide.updateGuide()
      expect(wrapGuide).toBeHidden()

  describe "when no lines exceed the guide column and the editor width is smaller than the guide column position", ->
    it "hides the guide", ->
      atom.workspaceView.width(10)
      editor.resize()
      wrapGuide.updateGuide()
      expect(wrapGuide).toBeHidden()

  it "only attaches to editors that are part of a pane", ->
    editor2 = new Editor(mini: true)
    editor.overlayer.append(editor2)
    expect(editor2.find('.wrap-guide').length).toBe 0
