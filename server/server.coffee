Meteor.publish('entries', (title) ->
    terms = {$or: [{'visibility': "public"}, {author: this.userId}]}
    term['$or'].push( { 'title': title } ) if title

    Entries.find(terms)
)


Meteor.publish('tags', -> return Tags.find({}))
