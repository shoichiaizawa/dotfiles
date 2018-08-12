# Your init script
#
# Atom will evaluate this file each time a new window is opened. It is run
# after packages are loaded/activated and after the previous editor state
# has been restored.
#
# An example hack to make opened Markdown files always be soft wrapped:
#
# path = require 'path'
#
# atom.workspaceView.eachEditorView (editorView) ->
#   editor = editorView.getEditor()
#   if path.extname(editor.getPath()) is '.md'
#     editor.setSoftWrap(true)
#
# An example hack to log to the console when each text editor is saved.
#
# atom.workspace.observeTextEditors (editor) ->
#   editor.onDidSave ->
#     console.log "Saved! #{editor.getPath()}"

# This script allows the user to escape from the Vim Insert Mode by pressing jk.
# See: https://github.com/atom/vim-mode/issues/334#issuecomment-85603175
atom.commands.add 'atom-text-editor', 'exit-insert-mode-if-preceded-by-j': (e) ->
  editor = @getModel()
  pos = editor.getCursorBufferPosition()
  range = [pos.traverse([0,-1]), pos]
  lastChar = editor.getTextInBufferRange(range)
  if lastChar != "j"
    e.abortKeyBinding()
  else
    editor.backspace()
    atom.commands.dispatch(e.currentTarget, 'vim-mode-plus:activate-normal-mode')

atom.commands.add 'atom-text-editor', 'select-character-line': (e) ->
  editor = @getModel()
  editor.moveToFirstCharacterOfLine()
  editor.selectToEndOfLine()
