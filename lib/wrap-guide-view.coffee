{$} = require 'atom'
rivets = require 'rivets'

rivets.configure
  prefix: 'atom'

rivets.binders['left'] = (el, value) ->
  el.style.left = "#{value}px"

module.exports =
class WrapGuideView
  content: """
    <div class="wrap-guide" atom-show="guide.visible" atom-left="guide.position">
    </div>
  """

  constructor: (guide, parentView) ->
    el = $(@content).appendTo(parentView)
    rivets.bind(el, {guide})
