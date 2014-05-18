ApplicationController = Ember.Controller.extend({
  needs: "authentication",

  actions: {
    login: ->
      @get('controllers.authentication').login()

    logout: ->
      @get('controllers.authentication').logout()
  }

})

`export default ApplicationController;`
