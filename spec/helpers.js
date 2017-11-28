module.exports = {
  getWrapGuides () {
    wrapGuides = []
    for (const editor of atom.workspace.getTextEditors()) {
      const guide = editor.getElement().querySelector('.wrap-guide')
      if (guide) wrapGuides.push(guide)
    }
    return wrapGuides
  },

  getLeftPosition (element) {
    return parseInt(element.style.left)
  }
}
