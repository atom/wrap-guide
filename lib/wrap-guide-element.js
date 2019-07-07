/*
 * decaffeinate suggestions:
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const { CompositeDisposable } = require('atom');

class WrapGuideElement {
  constructor(editor, editorElement) {
    this.editor = editor;
    this.editorElement = editorElement;
    this.subscriptions = new CompositeDisposable();
    this.configSubscriptions = new CompositeDisposable();
    this.element = document.createElement('div');
    this.element.setAttribute('is', 'wrap-guide');
    this.element.classList.add('wrap-guide-container');
    this.attachToLines();
    this.handleEvents();
    this.updateGuide();

    this.element.updateGuide = this.updateGuide.bind(this);
    this.element.getDefaultColumn = this.getDefaultColumn.bind(this);
  }

  attachToLines() {
    const scrollView = this.editorElement.querySelector('.scroll-view');
    return scrollView != null
      ? scrollView.appendChild(this.element)
      : undefined;
  }

  handleEvents() {
    const updateGuideCallback = () => this.updateGuide();

    this.handleConfigEvents();

    this.subscriptions.add(
      atom.config.onDidChange('editor.fontSize', async () => {
        // Wait for editor to finish updating before updating wrap guide
        await this.editorElement.getComponent().getNextUpdatePromise();

        updateGuideCallback();
      })
    );

    this.subscriptions.add(
      this.editorElement.onDidChangeScrollLeft(updateGuideCallback)
    );
    this.subscriptions.add(this.editor.onDidChangePath(updateGuideCallback));
    this.subscriptions.add(
      this.editor.onDidChangeGrammar(() => {
        this.configSubscriptions.dispose();
        this.handleConfigEvents();
        return updateGuideCallback();
      })
    );

    this.subscriptions.add(
      this.editor.onDidDestroy(() => {
        this.subscriptions.dispose();
        return this.configSubscriptions.dispose();
      })
    );

    return this.subscriptions.add(
      this.editorElement.onDidAttach(() => {
        this.attachToLines();
        return updateGuideCallback();
      })
    );
  }

  handleConfigEvents() {
    const { uniqueAscending } = require('./main');

    const updatePreferredLineLengthCallback = args => {
      // ensure that the right-most wrap guide is the preferredLineLength
      let columns = atom.config.get('wrap-guide.columns', {
        scope: this.editor.getRootScopeDescriptor()
      });
      if (columns.length > 0) {
        columns[columns.length - 1] = args.newValue;
        columns = uniqueAscending(columns.filter(i => i <= args.newValue));
        atom.config.set('wrap-guide.columns', columns, {
          scopeSelector: `.${this.editor.getGrammar().scopeName}`
        });
      }
      return this.updateGuide();
    };
    this.configSubscriptions.add(
      atom.config.onDidChange(
        'editor.preferredLineLength',
        { scope: this.editor.getRootScopeDescriptor() },
        updatePreferredLineLengthCallback
      )
    );

    const updateGuideCallback = () => this.updateGuide();
    this.configSubscriptions.add(
      atom.config.onDidChange(
        'wrap-guide.enabled',
        { scope: this.editor.getRootScopeDescriptor() },
        updateGuideCallback
      )
    );

    const updateGuidesCallback = args => {
      // ensure that multiple guides stay sorted in ascending order
      const columns = uniqueAscending(args.newValue);
      if (columns != null ? columns.length : undefined) {
        atom.config.set('wrap-guide.columns', columns);
        atom.config.set(
          'editor.preferredLineLength',
          columns[columns.length - 1],
          { scopeSelector: `.${this.editor.getGrammar().scopeName}` }
        );
        return this.updateGuide();
      }
    };
    return this.configSubscriptions.add(
      atom.config.onDidChange(
        'wrap-guide.columns',
        { scope: this.editor.getRootScopeDescriptor() },
        updateGuidesCallback
      )
    );
  }

  getDefaultColumn() {
    return atom.config.get('editor.preferredLineLength', {
      scope: this.editor.getRootScopeDescriptor()
    });
  }

  getGuidesColumns(path, scopeName) {
    const columns =
      atom.config.get('wrap-guide.columns', {
        scope: this.editor.getRootScopeDescriptor()
      }) || [];

    if (columns.length > 0) {
      return columns;
    }

    return [this.getDefaultColumn()];
  }

  isEnabled() {
    const isEnabled = atom.config.get('wrap-guide.enabled', {
      scope: this.editor.getRootScopeDescriptor()
    });

    return isEnabled != null ? isEnabled : true;
  }

  hide() {
    return (this.element.style.display = 'none');
  }

  show() {
    return (this.element.style.display = 'block');
  }

  updateGuide() {
    if (this.isEnabled()) {
      return this.updateGuides();
    }

    return this.hide();
  }

  updateGuides() {
    this.removeGuides();
    this.appendGuides();
    if (this.element.children.length) {
      return this.show();
    }

    return this.hide();
  }

  destroy() {
    this.element.remove();
    this.subscriptions.dispose();
    return this.configSubscriptions.dispose();
  }

  removeGuides() {
    while (this.element.firstChild) {
      this.element.removeChild(this.element.firstChild);
    }
  }

  appendGuides() {
    const columns = this.getGuidesColumns(
      this.editor.getPath(),
      this.editor.getGrammar().scopeName
    );

    for (const column of columns) {
      this.appendGuide(column);
    }
  }

  appendGuide(column) {
    let columnWidth = this.editorElement.getDefaultCharacterWidth() * column;
    columnWidth -= this.editorElement.getScrollLeft();
    const guide = document.createElement('div');
    guide.classList.add('wrap-guide');
    guide.style.left = `${Math.round(columnWidth)}px`;
    return this.element.appendChild(guide);
  }
}

module.exports = WrapGuideElement;
