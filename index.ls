angular.module \main, <[firebase]>
  ..controller \main, <[$scope $firebase render]> ++ ($scope, $firebase, render) ->
    $scope <<< do
      user: null
      mlogin:
        email: ""
        password: ""
        error: {}

    $scope.auth = new FirebaseSimpleLogin new Firebase("https://donmockup.firebaseio.com/"), (e, u) -> $scope.$apply ->
      console.log "user login:" ,u
      if e => return console.log "get user fail: ", e
      $scope.user = u

    $scope.logout = -> if $scope.user =>
      $scope.auth.logout!
      $scope <<< {email: "", password: "", user: null}

    $scope.login = ->
      if !$scope.user =>
        $scope.auth.createUser $scope.mlogin.email, $scope.mlogin.password, (e,u) ->
          if e and e.code == \EMAIL_TAKEN =>
            $scope.auth.login \password, email: $scope.mlogin.email, password: $scope.mlogin.password
          else if e =>
            console.log "create user error: ", e
          else => $scope.$apply -> $scope.user = u

    $scope.mvote = do
      id: null
      obj: null
      data: null
      allballot: {}
      plans: []
      ballot: []
      planCount: (plan) ->
        @allballot[plan.id] or 0
      planById: (id) ->
        ret = @plans.filter(-> it.id == id)
        if ret.length => return ret.0.name

      toggle: (plan) ->
        if !@id => return
        if !$scope.user => return
        planid = @plans.map -> it.id
        @metix.forEach ~> if not (it.$value in planid) => @metix.$remove it
        ret = @metix.filter ~> it.$value == plan.id
        if ret.length > 0 => ret.map ~> @metix.$remove it
        else if @metix.length < ( @obj.maxvote or 1) => @metix.$add plan.id

      add: ->
        db = $firebase(new Firebase "https://donmockup.firebaseio.com/vote")
        payload = {} <<< @{name,desc,plans}
        db.$add payload

      load: (id) ->
        @id = id
        obj = $firebase(new Firebase "https://donmockup.firebaseio.com/vote/#id")$asObject!
        obj.$loaded!then ~>
          @obj = obj
          @ <<< @obj{name, desc, maxvote, plans}
        alltix = $firebase(new Firebase "https://donmockup.firebaseio.com/vote/#id/tix")$asObject!
        alltix.$loaded!then ~>
          @alltix = alltix
          update = ~>
            @allballot = {}
            @alltix.forEach (ballot) ~>
               for k,v of ballot => 
                 if !@allballot[v] => @allballot[v] = 0
                 @allballot[v]++
          update!
          @alltix.$watch update

      save: ->
        if @obj => 
          @obj <<< @{name, desc, maxvote, plans}
          return @obj.$save!
        if !(@name) => return
        if !@obj => @add!
      
      delplan: (plan)->
        @plans.splice @plans.indexOf(plan),1

      newplan: ->
        @plans.push {name: @newplanname, id: new Date!getTime!}
    $scope.mvote.load \-JVeaoPJwNWyZH9I8VRT

        
    prepare-metix = ->
      if !($scope.mvote.id and $scope.user and $scope.user.uid) => return
      metix = $firebase(new Firebase "https://donmockup.firebaseio.com/vote/#{$scope.mvote.id}/tix/#{$scope.user.uid}")$asArray!
      metix.$loaded!then ->
        $scope.mvote.metix = metix
        update = -> $scope.mvote.ballot = $scope.mvote.metix.map -> it.$value
        update!
        $scope.mvote.metix.$watch update
    $scope.svg = document.getElementById(\svg)
    $scope.$watch 'user', -> prepare-metix!
    $scope.$watch 'mvote.id', -> prepare-metix!

    prepare-draw = ->
      console.log $scope.mvote.plans
      payload = $scope.mvote.plans.map -> 
        {value: ($scope.mvote.allballot[it.id] or 0)} <<< it{name, id}
      render.draw payload, $scope.svg

    $scope.$watch 'mvote.allballot', prepare-draw, true
    $scope.$watch 'mvote.plans', prepare-draw, true

    resize = ->
      [h,w] = [$(window)height!, $(window)width!]
      $(svg)width w - 40
      $(svg)height h - 200
    $(window)resize resize
    resize!
