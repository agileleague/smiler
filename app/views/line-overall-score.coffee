LineOverallScoreView = Ember.View.extend({
  templateName: "experiment/line-overall-score-view"

  didInsertElement: ->
    @_super()
    Ember.run.scheduleOnce('afterRender', @, ->
      @get('controller').send('buildChart')
    )
})

`export default LineOverallScoreView;`
