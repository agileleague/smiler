ExperimentRoute = Ember.Route.extend({
  actions: {
    toggleMobileMenu: ->
      $('body').toggleClass('mobile-menu-view')
  }

  renderTemplate: ->
    @render('experiment/main-sidebar',
      outlet: 'mainSidebar'
    )

    @render('experiment')
})

`export default ExperimentRoute;`
