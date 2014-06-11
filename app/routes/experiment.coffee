ExperimentRoute = Ember.Route.extend({
  renderTemplate: ->
    @render('experiment/main-sidebar',
      outlet: 'mainSidebar'
    )

    @render('experiment')
})

`export default ExperimentRoute;`
