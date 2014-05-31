ApplicationController = Ember.Controller.extend({
  needs: "authentication",

  actions: {
    login: (provider) ->
      @get('controllers.authentication').login(provider)

    logout: ->
      @get('controllers.authentication').logout()
  }

})

`export default ApplicationController;`
