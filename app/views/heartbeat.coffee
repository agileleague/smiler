HeartbeatView = Ember.View.extend({
  templateName: "experiment/heartbeat-view"

  didInsertElement: ->
    @_super()
    Ember.run.scheduleOnce('afterRender', @, ->
      @get('controller').send('buildChart')
    )
})

`export default HeartbeatView;`
