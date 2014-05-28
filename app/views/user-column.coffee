UserColumnView = Ember.View.extend({
  templateName: "experiment/user-column-view"

  didInsertElement: ->
    @_super()
    Ember.run.scheduleOnce('afterRender', @, ->
      @get('controller').send('buildChart')
    )
})

`export default UserColumnView;`
