Template.tag.events
    'click a': evtNavigate

Template.tag.tag = ->
    Session.get( 'tag' )

Template.tag.results = ->
    tag = Session.get('tag')

    return unless tag
    
    entries = Entries.find( { tags: tag } )
    EntryLib.getSummaries( entries )
