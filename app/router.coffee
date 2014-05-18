Router = Ember.Router.extend({
  location: ENV.locationType
})

Router.map ->
  @resource('experiments', ->
    @route('new')
  )
  @resource('experiment', { path: '/experiment/:experiment_id' })

`export default Router;`
