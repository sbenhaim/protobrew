Template.search.term = -> Session.get( 'search-term' )

Template.search.results = ->
  term = Session.get('search-term')

  return unless term
    
  # entries = Entries.find( {text: new RegExp( term, "i" )} )

  entries = Entries.find
    $or: [
      text: new RegExp( term, "i" )
    ,
      title: new RegExp( term, "i" )
    ]
  EntryLib.getSummaries( entries )


Template.search.events
  'click a': evtNavigate


