{RootView} = require 'atom'
WrapGuide = require '../lib/wrap-guide'

describe "WrapGuide", ->
  [editor, wrapGuide] = []

  beforeEach ->
    window.rootView = new RootView
    rootView.openSync('sample.js')
    editor = rootView.getActiveView()
    wrapGuide = new WrapGuide(editor)

  it "has a default column position", ->
    expect(wrapGuide.getDefaultColumn()).toBeGreaterThan 0

  describe "using a custom config column", ->
    it "places the wrap guide at the custom column", ->
      config.set('wrapGuide.columns', [{pattern: '\.js$', column: 20}])
      wrapGuide.updateGuide()
      width = editor.charWidth * 20
      expect(wrapGuide.position).toBe width

    it "uses the default column when no custom column matches the path", ->
      config.set('wrapGuide.columns', [{pattern: '\.jsp$', column: '100'}])
      wrapGuide.updateGuide()
      width = editor.charWidth * wrapGuide.getDefaultColumn()
      expect(wrapGuide.position).toBe width

    it "hides the guide when the config column is less than 1", ->
      config.set('wrapGuide.columns', [{pattern: 'sample\.js$', column: -1}])
      wrapGuide.updateGuide()
      expect(wrapGuide.visible).toBe false

  describe "when no lines exceed the guide column and the editor width is smaller than the guide column position", ->
    it "hides the guide", ->
      rootView.width(10)
      editor.resize()
      wrapGuide.updateGuide()
      expect(wrapGuide.visible).toBe false

  describe "when the font size changes", ->
    it "updates the wrap guide position", ->
      spyOn(wrapGuide, 'updateGuide')
      fontSize = atom.config.get("editor.fontSize")
      atom.config.set("editor.fontSize", fontSize + 10)
      expect(wrapGuide.updateGuide.callCount).toBe 1
