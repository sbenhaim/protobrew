Template.comment_form.rendered = function(){
  if(Meteor.user() && !this.editor){
    el = $( '#comment' );
    console.log('rendered');
    el.redactor({
      plugins: ['autoSuggest'],
      imageUpload: '/images',
      buttons: ['html', '|', 'formatting', '|', 'bold', 'italic', 'deleted', '|', 'unorderedlist', 'orderedlist', 'outdent', 'indent', '|', 'image', 'table', 'link', '|', 'fontcolor', 'backcolor', '|', 'alignment', '|', 'horizontalrule'],
      focus: true,
      autoresize: true,
      filepicker: function(callback) {
        filepicker.setKey('AjmU2eDdtRDyMpagSeV7rz');
        return filepicker.pick({
          mimetype: "image/*"
        }, function(file) {
          return filepicker.store(file, {
            location: "S3",
            path: Meteor.userId() + "/" + file.filename
          }, function(file) {
            return callback({
              filelink: file.url
            });
          });
        });
      }
    });

    // this.editor = new EpicEditor(EpicEditorOptions).load();
    // $(this.editor.editor).bind('keydown', 'meta+return', function(){
    //   $(window.editor).closest('form').find('input[type="submit"]').click();
    // });
  }
}

Template.comment_form.helpers({
  addingComment: function(){
    return Session.equals('addingComment', true);
  }
});

Template.comment_form.events = {
  'click .comment-add': function(e){
    e.preventDefault();
    Session.set('addingComment', true);
  },
  'click .comment-cancel': function(e){
    e.preventDefault();
    Session.set('addingComment', false);
  },
  'click .comment-save': function(e){
    e.preventDefault();

    var content  = $('#comment').val();
    var parentCommentId=null;        
    var entryId=Session.get('entryId');

    Meteor.call('comment', entryId, parentCommentId, content, function(error, commentProperties){
        if(error){
            console.log(error);
            Toast.error(error.reason);
        }else{
            // trackEvent("newComment", commentProperties);
            Session.set('scrollToCommentId', commentProperties.commentId);
            // instance.editor.importFile('editor', '');
        }
    });
    Session.set('addingComment', false);
  }
};
