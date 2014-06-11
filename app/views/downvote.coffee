DownvoteView = Ember.View.extend({
  templateName: "downvote"

  tagName: 'span'

  click: (e) ->
    e.preventDefault()
    @get('controller').send('downVote')

})

`export default DownvoteView;`
