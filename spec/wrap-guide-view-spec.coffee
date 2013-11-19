{Editor, RootView} = require 'atom'

describe "WrapGuideView", ->
  [editor, wrapGuide] = []

  beforeEach ->
    window.rootView = new RootView
    rootView.openSync('sample.js')
    atom.activatePackage('wrap-guide')
    rootView.attachToDom()
    rootView.height(200)
    rootView.width(1500)
    editor = rootView.getActiveView()
    wrapGuide = rootView.find('.wrap-guide')
    editor.width(editor.charWidth * 80 * 2)
    editor.trigger 'resize'

  describe "@initialize", ->
    it "appends a wrap guide to all existing and new editors", ->
      expect(rootView.panes.find('.underlayer > .wrap-guide').length).toBe 1
      expect(rootView.panes.find('.underlayer > .wrap-guide').position().left).toBeGreaterThan(0)
      expect(wrapGuide).toBeVisible()
      editor.splitRight()
      expect(rootView.find('.pane').length).toBe 2
      expect(rootView.panes.find('.underlayer > .wrap-guide').length).toBe 2

  describe "when the font size changes", ->
    it "updates the wrap guide position", ->
      initial = wrapGuide.position().left
      expect(initial).toBeGreaterThan(0)
      fontSize = config.get("editor.fontSize")
      config.set("editor.fontSize", fontSize + 10)
      expect(wrapGuide.position().left).toBeGreaterThan(initial)
      expect(wrapGuide).toBeVisible()

  it "only attaches to editors that are part of a pane", ->
    editor2 = new Editor(mini: true)
    editor.overlayer.append(editor2)
    expect(editor2.find('.wrap-guide').length).toBe 0
