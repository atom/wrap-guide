const { getLeftPosition, getLeftPositions } = require('./helpers');
const { uniqueAscending } = require('../lib/main');

describe('WrapGuideElement', function() {
  let [editor, editorElement, wrapGuide, workspaceElement] = Array.from([]);

  beforeEach(function() {
    workspaceElement = atom.views.getView(atom.workspace);
    workspaceElement.style.height = '200px';
    workspaceElement.style.width = '1500px';

    jasmine.attachToDOM(workspaceElement);

    waitsForPromise(() => atom.packages.activatePackage('wrap-guide'));

    waitsForPromise(() => atom.packages.activatePackage('language-javascript'));

    waitsForPromise(() =>
      atom.packages.activatePackage('language-coffee-script')
    );

    waitsForPromise(() => atom.workspace.open('sample.js'));

    return runs(function() {
      editor = atom.workspace.getActiveTextEditor();
      editorElement = editor.getElement();
      return (wrapGuide = editorElement.querySelector('.wrap-guide-container'));
    });
  });

  describe('.activate', function() {
    const getWrapGuides = function() {
      const wrapGuides = [];
      atom.workspace.getTextEditors().forEach(function(editor) {
        const guides = editor.getElement().querySelectorAll('.wrap-guide');
        if (guides) {
          return wrapGuides.push(guides);
        }
      });
      return wrapGuides;
    };

    it('appends a wrap guide to all existing and new editors', function() {
      expect(atom.workspace.getTextEditors().length).toBe(1);

      expect(getWrapGuides().length).toBe(1);
      expect(getLeftPosition(getWrapGuides()[0][0])).toBeGreaterThan(0);

      atom.workspace.getActivePane().splitRight({ copyActiveItem: true });
      expect(atom.workspace.getTextEditors().length).toBe(2);
      expect(getWrapGuides().length).toBe(2);
      expect(getLeftPosition(getWrapGuides()[0][0])).toBeGreaterThan(0);
      return expect(getLeftPosition(getWrapGuides()[1][0])).toBeGreaterThan(0);
    });

    it('positions the guide at the configured column', function() {
      const width = editor.getDefaultCharWidth() * wrapGuide.getDefaultColumn();
      expect(width).toBeGreaterThan(0);
      expect(
        Math.abs(getLeftPosition(wrapGuide.firstChild) - width)
      ).toBeLessThan(1);
      return expect(wrapGuide).toBeVisible();
    });

    it('appends multiple wrap guides to all existing and new editors', function() {
      const columns = [10, 20, 30];
      atom.config.set('wrap-guide.columns', columns);

      waitsForPromise(() =>
        editorElement.getComponent().getNextUpdatePromise()
      );

      return runs(function() {
        expect(atom.workspace.getTextEditors().length).toBe(1);
        expect(getWrapGuides().length).toBe(1);
        const positions = getLeftPositions(getWrapGuides()[0]);
        expect(positions.length).toBe(columns.length);
        expect(positions[0]).toBeGreaterThan(0);
        expect(positions[1]).toBeGreaterThan(positions[0]);
        expect(positions[2]).toBeGreaterThan(positions[1]);

        atom.workspace.getActivePane().splitRight({ copyActiveItem: true });
        expect(atom.workspace.getTextEditors().length).toBe(2);
        expect(getWrapGuides().length).toBe(2);
        const pane1_positions = getLeftPositions(getWrapGuides()[0]);
        expect(pane1_positions.length).toBe(columns.length);
        expect(pane1_positions[0]).toBeGreaterThan(0);
        expect(pane1_positions[1]).toBeGreaterThan(pane1_positions[0]);
        expect(pane1_positions[2]).toBeGreaterThan(pane1_positions[1]);
        const pane2_positions = getLeftPositions(getWrapGuides()[1]);
        expect(pane2_positions.length).toBe(pane1_positions.length);
        expect(pane2_positions[0]).toBe(pane1_positions[0]);
        expect(pane2_positions[1]).toBe(pane1_positions[1]);
        return expect(pane2_positions[2]).toBe(pane1_positions[2]);
      });
    });

    return it('positions multiple guides at the configured columns', function() {
      const columnCount = 5;
      const columns = __range__(1, columnCount, true).map(c => c * 10);
      atom.config.set('wrap-guide.columns', columns);
      waitsForPromise(() =>
        editorElement.getComponent().getNextUpdatePromise()
      );

      return runs(function() {
        const positions = getLeftPositions(getWrapGuides()[0]);
        expect(positions.length).toBe(columnCount);
        expect(wrapGuide.children.length).toBe(columnCount);

        for (let i of Array.from(columnCount - 1)) {
          const width = editor.getDefaultCharWidth() * columns[i];
          expect(width).toBeGreaterThan(0);
          expect(
            Math.abs(getLeftPosition(wrapGuide.children[i]) - width)
          ).toBeLessThan(1);
        }
        return expect(wrapGuide).toBeVisible();
      });
    });
  });

  describe('when the font size changes', function() {
    it('updates the wrap guide position', function() {
      const initial = getLeftPosition(wrapGuide.firstChild);
      expect(initial).toBeGreaterThan(0);
      const fontSize = atom.config.get('editor.fontSize');
      atom.config.set('editor.fontSize', fontSize + 10);

      waitsForPromise(() =>
        editorElement.getComponent().getNextUpdatePromise()
      );

      return runs(function() {
        expect(getLeftPosition(wrapGuide.firstChild)).toBeGreaterThan(initial);
        return expect(wrapGuide.firstChild).toBeVisible();
      });
    });

    return it('updates the wrap guide position for hidden editors when they become visible', function() {
      const initial = getLeftPosition(wrapGuide.firstChild);
      expect(initial).toBeGreaterThan(0);

      waitsForPromise(() => atom.workspace.open());

      return runs(function() {
        const fontSize = atom.config.get('editor.fontSize');
        atom.config.set('editor.fontSize', fontSize + 10);
        atom.workspace.getActivePane().activatePreviousItem();

        waitsForPromise(() =>
          editorElement.getComponent().getNextUpdatePromise()
        );

        return runs(function() {
          expect(getLeftPosition(wrapGuide.firstChild)).toBeGreaterThan(
            initial
          );
          return expect(wrapGuide.firstChild).toBeVisible();
        });
      });
    });
  });

  describe('when the column config changes', () =>
    it('updates the wrap guide position', function() {
      const initial = getLeftPosition(wrapGuide.firstChild);
      expect(initial).toBeGreaterThan(0);
      const column = atom.config.get('editor.preferredLineLength');
      atom.config.set('editor.preferredLineLength', column + 10);
      expect(getLeftPosition(wrapGuide.firstChild)).toBeGreaterThan(initial);
      return expect(wrapGuide).toBeVisible();
    }));

  describe('when the preferredLineLength changes', () =>
    it('updates the wrap guide positions', function() {
      const initial = [10, 15, 20, 30];
      atom.config.set('wrap-guide.columns', initial, {
        scopeSelector: `.${editor.getGrammar().scopeName}`
      });
      waitsForPromise(() =>
        editorElement.getComponent().getNextUpdatePromise()
      );

      return runs(function() {
        atom.config.set('editor.preferredLineLength', 15, {
          scopeSelector: `.${editor.getGrammar().scopeName}`
        });
        waitsForPromise(() =>
          editorElement.getComponent().getNextUpdatePromise()
        );

        return runs(function() {
          const columns = atom.config.get('wrap-guide.columns', {
            scope: editor.getRootScopeDescriptor()
          });
          expect(columns.length).toBe(2);
          expect(columns[0]).toBe(10);
          return expect(columns[1]).toBe(15);
        });
      });
    }));

  describe('when the columns config changes', function() {
    it('updates the wrap guide positions', function() {
      const initial = getLeftPositions(wrapGuide.children);
      expect(initial.length).toBe(1);
      expect(initial[0]).toBeGreaterThan(0);

      const columns = [10, 20, 30];
      atom.config.set('wrap-guide.columns', columns);
      waitsForPromise(() =>
        editorElement.getComponent().getNextUpdatePromise()
      );

      return runs(function() {
        const positions = getLeftPositions(wrapGuide.children);
        expect(positions.length).toBe(columns.length);
        expect(positions[0]).toBeGreaterThan(0);
        expect(positions[1]).toBeGreaterThan(positions[0]);
        expect(positions[2]).toBeGreaterThan(positions[1]);
        return expect(wrapGuide).toBeVisible();
      });
    });

    it('updates the preferredLineLength', function() {
      const initial = atom.config.get('editor.preferredLineLength', {
        scope: editor.getRootScopeDescriptor()
      });
      atom.config.set('wrap-guide.columns', [initial, initial + 10]);
      waitsForPromise(() =>
        editorElement.getComponent().getNextUpdatePromise()
      );

      return runs(function() {
        const length = atom.config.get('editor.preferredLineLength', {
          scope: editor.getRootScopeDescriptor()
        });
        return expect(length).toBe(initial + 10);
      });
    });

    return it('keeps guide positions unique and in ascending order', function() {
      const initial = getLeftPositions(wrapGuide.children);
      expect(initial.length).toBe(1);
      expect(initial[0]).toBeGreaterThan(0);

      const reverseColumns = [30, 20, 10];
      const columns = [
        reverseColumns[reverseColumns.length - 1],
        ...Array.from(reverseColumns),
        reverseColumns[0]
      ];
      const uniqueColumns = uniqueAscending(columns);
      expect(uniqueColumns.length).toBe(3);
      expect(uniqueColumns[0]).toBeGreaterThan(0);
      expect(uniqueColumns[1]).toBeGreaterThan(uniqueColumns[0]);
      expect(uniqueColumns[2]).toBeGreaterThan(uniqueColumns[1]);

      atom.config.set('wrap-guide.columns', columns);
      waitsForPromise(() =>
        editorElement.getComponent().getNextUpdatePromise()
      );

      return runs(function() {
        const positions = getLeftPositions(wrapGuide.children);
        expect(positions.length).toBe(uniqueColumns.length);
        expect(positions[0]).toBeGreaterThan(0);
        expect(positions[1]).toBeGreaterThan(positions[0]);
        expect(positions[2]).toBeGreaterThan(positions[1]);
        return expect(wrapGuide).toBeVisible();
      });
    });
  });

  describe("when the editor's scroll left changes", () =>
    it('updates the wrap guide position to a relative position on screen', function() {
      editor.setText('a long line which causes the editor to scroll');
      editorElement.style.width = '100px';

      waitsFor(() => editorElement.component.getMaxScrollLeft() > 10);

      return runs(function() {
        const initial = getLeftPosition(wrapGuide.firstChild);
        expect(initial).toBeGreaterThan(0);
        editorElement.setScrollLeft(10);
        expect(getLeftPosition(wrapGuide.firstChild)).toBe(initial - 10);
        return expect(wrapGuide.firstChild).toBeVisible();
      });
    }));

  describe("when the editor's grammar changes", function() {
    it('updates the wrap guide position', function() {
      atom.config.set('editor.preferredLineLength', 20, {
        scopeSelector: '.source.js'
      });
      const initial = getLeftPosition(wrapGuide.firstChild);
      expect(initial).toBeGreaterThan(0);
      expect(wrapGuide).toBeVisible();

      editor.setGrammar(
        atom.grammars.grammarForScopeName('text.plain.null-grammar')
      );
      expect(getLeftPosition(wrapGuide.firstChild)).toBeGreaterThan(initial);
      return expect(wrapGuide).toBeVisible();
    });

    it('listens for preferredLineLength updates for the new grammar', function() {
      editor.setGrammar(atom.grammars.grammarForScopeName('source.coffee'));
      const initial = getLeftPosition(wrapGuide.firstChild);
      atom.config.set('editor.preferredLineLength', 20, {
        scopeSelector: '.source.coffee'
      });
      return expect(getLeftPosition(wrapGuide.firstChild)).toBeLessThan(
        initial
      );
    });

    return it('listens for wrap-guide.enabled updates for the new grammar', function() {
      editor.setGrammar(atom.grammars.grammarForScopeName('source.coffee'));
      expect(wrapGuide).toBeVisible();
      atom.config.set('wrap-guide.enabled', false, {
        scopeSelector: '.source.coffee'
      });
      return expect(wrapGuide).not.toBeVisible();
    });
  });

  return describe('scoped config', function() {
    it('::getDefaultColumn returns the scope-specific column value', function() {
      atom.config.set('editor.preferredLineLength', 132, {
        scopeSelector: '.source.js'
      });

      return expect(wrapGuide.getDefaultColumn()).toBe(132);
    });

    it('updates the guide when the scope-specific column changes', function() {
      const initial = getLeftPosition(wrapGuide.firstChild);
      const column = atom.config.get('editor.preferredLineLength', {
        scope: editor.getRootScopeDescriptor()
      });
      atom.config.set('editor.preferredLineLength', column + 10, {
        scope: '.source.js'
      });
      return expect(getLeftPosition(wrapGuide.firstChild)).toBeGreaterThan(
        initial
      );
    });

    return it('updates the guide when wrap-guide.enabled is set to false', function() {
      expect(wrapGuide).toBeVisible();

      atom.config.set('wrap-guide.enabled', false, {
        scopeSelector: '.source.js'
      });

      return expect(wrapGuide).not.toBeVisible();
    });
  });
});

function __range__(left, right, inclusive) {
  let range = [];
  let ascending = left < right;
  let end = !inclusive ? right : ascending ? right + 1 : right - 1;
  for (let i = left; ascending ? i < end : i > end; ascending ? i++ : i--) {
    range.push(i);
  }
  return range;
}
