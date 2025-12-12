def setup
  Scintilla::ScintillaGtk.gtk_init
  Scintilla::ScintillaGtk.new
end

assert('SCI_SETTEXT') do
  st = setup
  st.SCI_SETTEXT('hogehoge')
  assert_equal 'hog', st.sci_get_text(3)
end

assert('SCI_AUTOCSELECT') do
  st = setup
  st.SCI_AUTOCSHOW(0, 'aaa bbb ccc')
  st.sci_autoc_select('bbb')
  assert_equal true, st.sci_autoc_active
end

assert('SCI_GETTARGETTEXT') do
  st = setup
  st.SCI_INSERTTEXT(0, 'abcdefg')
  st.SCI_SETTARGETSTART(1)
  st.SCI_SETTARGETEND(5)
  assert_equal 'bcde', st.SCI_GETTARGETTEXT
end

assert('SCI_AUTOCGETCURRENTTEXT') do
  st = setup
  st.SCI_AUTOCSHOW(0, 'abc xyz')
  assert_equal 'abc', st.SCI_AUTOCGETCURRENTTEXT
end

assert('SCI_ANNOTATIONGETTEXT') do
  st = setup
  st.SCI_ANNOTATIONSETTEXT(0, 'abcd')
  assert_equal 'abcd', st.SCI_ANNOTATIONGETTEXT
end

assert('SCI_GETCURLINE') do
  st = setup
  st.SCI_INSERTTEXT(0, 'abcdefg')
  st.SCI_CHARRIGHT
  assert_equal ['abcdefg', 1], st.sci_get_curline
  st.SCI_LINEEND
  st.SCI_NEWLINE
  st.SCI_DOCUMENTEND
  st.SCI_ADDTEXT(7, 'xyz')
  assert_equal ['xyz', 7], st.SCI_GETCURLINE
end

assert('SCI_GETTEXT') do
  st = setup
  st.SCI_INSERTTEXT(0, 'abcdefg')
  assert_equal 'abc', st.sci_get_text(3)
  assert_equal 'abcde', st.SCI_GETTEXT(5)
end

assert('SCI_GETSELTEXT') do
  st = setup
  st.SCI_INSERTTEXT(0, 'abcdefg')
  assert_equal '', st.sci_get_seltext
  st.SCI_SELECTALL
  assert_equal 'abcdefg', st.SCI_GETSELTEXT
end

assert('SCI_GETPROPERTY') do
  st = setup
  st.sci_set_lexer_language('ruby')
  st.SCI_SETPROPERTY('fold.compact', '1')
  assert_equal '1', st.sci_get_property('fold.compact')
end

assert('SCI_GETLINE') do
  st = setup
  st.SCI_INSERTTEXT(0, 'abcdefg')
  st.SCI_CHARRIGHT
  assert_equal 'abcdefg', st.sci_get_line(0)
  st.SCI_LINEEND
  st.SCI_NEWLINE
  st.SCI_DOCUMENTEND
  st.SCI_ADDTEXT(7, 'xyz')
  st.SCI_LINEEND
  st.SCI_NEWLINE
  assert_equal 'xyz', st.SCI_GETLINE(1)
end

assert('SCI_GETWORDCHARS') do
  st = setup
  st.SCI_SETWORDCHARS(0, 'abcde')
  assert_equal 5, st.sci_get_wordchars.length
  st.SCI_SETWORDCHARS(0, 'abcdefghijklmn')
  assert_equal 14, st.SCI_GETWORDCHARS.length
end

assert('SCI_GETLEXERLANGUAGE') do
  st = setup
  st.sci_set_lexer_language('ruby')
  assert_equal 'ruby', st.sci_get_lexer_language
  st.sci_set_lexer_language('yaml')
  assert_equal 'yaml', st.SCI_GETLEXERLANGUAGE
end

assert('SCI_MARGINGETTEXT') do
  st = setup
  st.SCI_NEWLINE
  st.sci_margin_set_text(0, 'aaa')
  assert_equal 'aaa', st.sci_margin_get_text(0)
  st.sci_margin_set_text(1, 'bbbb')
  assert_equal 'bbbb', st.SCI_MARGINGETTEXT(1)
end

assert('SCI_GETDOCPOINTER') do
  st = setup
  doc = st.SCI_GETDOCPOINTER
  assert_kind_of Scintilla::Document, doc
end

assert('SCI_CREATEDOCUMENT') do
  st = setup
  assert_equal 0, st.SCI_GETDOCUMENTOPTIONS
  doc = st.SCI_CREATEDOCUMENT(0, 0x100)
  assert_kind_of Scintilla::Document, doc
  st.sci_set_docpointer(doc)
  assert_equal 0x100, st.SCI_GETDOCUMENTOPTIONS
end

assert('SCI_SETDOCPOINTER') do
  st = setup
  doc = st.sci_get_docpointer
  st.sci_set_docpointer(nil)
  assert_not_equal st.sci_get_docpointer, doc
end

assert('SCI_ADDREFDOCUMENT') do
  st = setup
  doc = st.sci_getdocpointer
  assert_equal 0, st.SCI_ADDREFDOCUMENT(doc)
end

assert('SCI_RELEASEDOCUMENT') do
  st = setup
  doc = st.sci_createdocument
  assert_equal 0, st.SCI_RELEASEDOCUMENT(doc)
end

assert('SCI_SETILEXER') do
  st = setup
  lexer = Scintilla.create_lexer('ruby')
  st.SCI_SETILEXER(lexer)
  assert_equal 'ruby', st.SCI_GETLEXERLANGUAGE
end
