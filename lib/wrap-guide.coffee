{Subscriber} = require 'emissary'

# TODO: Remove when editor emits resize events
{$} = require 'atom'

class Model

  constructor: ->
    @observers = {}
    @watchObservables(@observables)

  watchObservables: (properties) ->
    @observableProperties ?= {}

    for name, value of properties ? {}
      @observableProperties[name] = value
      do (name, value) =>
        Object.defineProperty this, name,
          get: => @observableProperties[name]
          set: (value) =>
            @observableProperties[name] = value
            @notifyObservers({name})

  observe: (properties, cb) ->
    for property in properties.split(' ') when property
      @observers[property] ?= []
      @observers[property].push(cb)

  # Private
  notifyObservers: ({name}) ->
    for observer in @observers[name] ? []
      observer(newValue: @[name])

module.exports =
class WrapGuide extends Model
  Subscriber.includeInto(this)

  observables:
    columnPosition: 0
    columnVisible: false

  constructor: (@editor) ->
    super
    @subscribe atom.config.observe 'editor.fontSize', => @updateGuide()
    @subscribe @editor, 'editor:path-changed editor:min-width-changed', => @updateGuide()
    @subscribe $(window), 'resize', => @updateGuide()

    @updateGuide()

  getDefaultColumn: ->
    atom.config.getPositiveInt('editor.preferredLineLength', 80)

  getGuideColumn: (path) ->
    customColumns = atom.config.get('wrapGuide.columns')

    for customColumn in customColumns ? []
      {pattern, column} = customColumn ? {}
      pathMatches = new RegExp(pattern).test(path)
      return parseInt(column) if pathMatches

    @getDefaultColumn()

  updateGuide: ->
    column = @getGuideColumn(@editor.getPath())
    columnVisible = false

    if column > 0
      columnPosition = @editor.charWidth * column
      if columnPosition < @editor.layerMinWidth or columnPosition < @editor.width()
        @columnPosition = columnPosition
        columnVisible = true

    @columnVisible = columnVisible
