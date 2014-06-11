UpvoteView = Ember.View.extend({
  templateName: "upvote"

  tagName: 'span'

  click: (e) ->
    e.preventDefault()
    @get('controller').send('upVote')

})

`export default UpvoteView;`
