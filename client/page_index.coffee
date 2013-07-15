Template.pageindex.test = ->
    context = Session.get('context')
    entry = findSingleEntryByTitle('Articles', context)
    
#    x = $('<div>')
#    x.html(entry.text)
#    console.log(entry.text)
    for el in $("<div>"+entry.text+"</div>").find( 'a')
         href = $(el).attr('href')
         if (href.indexOf "/") == 0
             console.log("hey"+href)
    "hello"