DownvoteView = Ember.View.extend({
  templateName: "downvote"

  click: (e) ->
    e.preventDefault()
    @get('controller').send('downVote')

})

`export default DownvoteView;`
