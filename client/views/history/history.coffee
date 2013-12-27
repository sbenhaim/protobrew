Template.history.revisions = ->
  title = Session.get("title")
  if title
    findRevisionsByTitle(title)
  else
    console.log "No revs found."
    []

Template.history.getUserName = (userID) ->
  UserLib.getDisplayNameById(userID)

Template.history.entry = ->
  Entries.findOne({title: Session.get("title")})

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

Template.compare.diff = ->
  revId1 = Session.get('rev1')
  revId2 = Session.get('rev2')
  rev1 = findRevisionById revId1
  rev2 = findRevisionById revId2
  console.log("rev1", rev1.text)
  console.log("rev2", rev2.text)
  console.log("diff", htmldiff(rev1.text, rev2.text))
  return htmldiff(rev2.text, rev1.text)
