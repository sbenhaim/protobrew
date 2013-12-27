Template.compare.diff = ->
  revId1 = Session.get('rev1')
  revId2 = Session.get('rev2')
  rev1 = findRevisionById revId1
  rev2 = findRevisionById revId2
  console.log("rev1", rev1.text)
  console.log("rev2", rev2.text)
  console.log("diff", htmldiff(rev1.text, rev2.text))
  return htmldiff(rev2.text, rev1.text)
