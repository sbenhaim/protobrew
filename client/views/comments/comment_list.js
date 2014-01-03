Template.comment_list.helpers({

  has_comments: function(){
    var entry = Entries.findOne(Session.get('entryId'));
    if(entry){
      return Comments.find({entry: entry._id, parent: null}).count() > 0;
    }
  },
  child_comments: function(){
    var entry = Entries.findOne(Session.get('entryId'));
    return Comments.find({entry: entry._id, parent: null}, {sort: {score: -1, submitted: -1}});
  }
})