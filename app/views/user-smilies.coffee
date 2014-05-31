UserSmiliesView = Ember.View.extend({
  templateName: "experiment/user-smilies-view"

  didInsertElement: ->
    @_super()
    Ember.run.scheduleOnce('afterRender', @, ->
      @get('controller').send('buildChart')
    )
})

`export default UserSmiliesView;`
