Template.history.revisions = ->
  title = Session.get("title")
  if title
    findRevisionsByTitle(title)
  else
    console.log "No revs found."
    []

Template.history.getUserName = (userID) ->
  UserLib.getDisplayNameById(userID)

Template.history.events
  'click #compareSelected': (evt) ->
    evt.preventDefault()
    rev1 = $('.historyForm input[name=rev1]:checked').val()
    rev2 = $('.historyForm input[name=rev2]:checked').val()
    if rev1? and rev2?
      navigate('/compare/' + Session.get('title') + '/' + rev1 + '/' + rev2)
    else
      $('.compareRadio').queue (next) ->
        $(this).addClass 'compareRadioRed'
        next()
      $('.compareRadio').delay 1000
      $('.compareRadio').queue (next) ->
        $(this).removeClass 'compareRadioRed'
        next()

#
# Revision compare template helpers
#

_htmlHash = {}
_currentHash = 44032
_is_debug = false;

pushHash = (tag) ->
  if not _htmlHash.tag?
    _htmlHash[tag] = eval('"\\u' + _currentHash.toString(16) + '"')
    _currentHash++
  _htmlHash[tag]

clearHash = ->
  _htmlHash = {}
  # 朝鲜文音节 Hangul Syllablesp
  _currentHash = 44032

html2plain = (html) ->
  html = html.replace /<(S*?)[^>]*>.*?|<.*?\/>/g, (tag) ->
    if _is_debug
      return pushHash(tag.toUpperCase().replace(/</g, '&lt;').replace(/>/g, '&gt;'))
    else
      return pushHash(tag.toUpperCase())
  html

plain2html = (plain) ->
  for tag, c of _htmlHash
    plain = plain.replace RegExp(c, 'g'), tag
  plain


# History comparison rendered function
Template.compare.rendered = ->
  revId1 = Session.get('rev1')
  revId2 = Session.get('rev2')
  console.log(revId1, revId2)
  rev1 = findRevisionById revId1
  rev2 = findRevisionById revId2
  if rev1 and rev2
    revText1 = html2plain(rev1.text)
    revText2 = html2plain(rev2.text)

    $("#compareTitle").text("Comparing revision #{rev1.date} to revision #{rev2.date}")

    $("#rev1").text(revText1).hide()
    $("#rev2").text(revText2).hide()
    $("#revCompare").prettyTextDiff({
      originalContainer: "#rev1",
      changedContainer: "#rev2",
      diffContainer: "#diffView",
      cleanup: true,
      debug: true
    });
    # TODO: plain2html the diff result.
    diffText = plain2html($("#diffView").html()).replace(/<br>/gi, '')
    $("#diffView").html(diffText)
