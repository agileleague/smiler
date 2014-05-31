AuthenticationController = Ember.Controller.extend({
  currentUser: null,

  init: ->
    @set('firebaseRef', new Firebase(window.ENV.FIREBASE_URL))
    @set('authRef', new FirebaseSimpleLogin(@get('firebaseRef'), (error, userResp) =>
      if error
        # Error
        console.log(error)
      else if userResp
        # Login
        @store.find('user', userResp.uid)
        .then( (u) =>
          user = u
          @set('currentUser', user)
        ).catch( (reason) =>
          # User not found
          userData = @initUser(userResp)
          user = @store.createRecord('user', userData)
          user.save()

          .then( =>
            @set('currentUser', user)
          )
        )

      else
        # Logout
        @set('currentUser', null)
    ))

  isModerator:( ->
    if @get('currentUser.isModerator') then true else false
  ).property('currentUser.isModerator')

  isLoggedIn:( ->
    if @get('currentUser.id') then true else false
  ).property('currentUser')


  login: (provider) ->
    @get('authRef').login(provider)

  logout: ->
    @get('authRef').logout()


  initUser: (userResponse) ->
    userData = {
      id: userResponse.uid,
      displayName: userResponse.displayName,
      isModerator: false,
      provider: userResponse.provider
    }
    if userResponse.provider == 'github'
      userData.username = userResponse.username
      userData.avatarUrl = userResponse.thirdPartyUserData.avatar_url
    else if userResponse.provider == 'facebook'
      userData.username = userResponse.thirdPartyUserData.name
      userData.avatarUrl = "http://graph.facebook.com/#{userResponse.thirdPartyUserData.id}/picture?type=large"
    else if userResponse.provider == 'google'
      userData.username = userResponse.displayName
      userData.avatarUrl = userResponse.thirdPartyUserData.picture

    userData

})

`export default AuthenticationController;`
