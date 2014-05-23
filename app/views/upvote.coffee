UpvoteView = Ember.View.extend({
  templateName: "upvote"

  click: (e) ->
    e.preventDefault()
    @get('controller').send('upVote')

})

`export default UpvoteView;`
