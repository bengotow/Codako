@NavCtrl = ($scope, $location, Auth, $http, $cookieStore) ->
  $scope.navigationItems = []

  Auth.withUser (error, user) ->
      $scope.$apply() unless $scope.$$phase


  $scope.navigationItemMatching = (label, href = '#') ->
    # why do we have to find matching items? If we don't reuse the same JSON hashes
    # each time we build the navigation and rebuild it from scratch each time, Angular
    # freaks out that the data isn't stabalizing.
    for item in $scope.navigationItems
      if item.label == label
        return item

    item = {label: label, href: href}
    $scope.navigationItems.push(item)
    return item

  $scope.rebuildNavigationClasses = (items) ->
    for item in items
      if "/##{$location.$$path}".indexOf(item.href) != -1
        item.class = 'active'
      else
        item.class = ''


  $scope.navigation = (side) ->
    items = []

    if side == 'left'
      items.push($scope.navigationItemMatching('Home', '/#/home'))
      if Auth.user()
        items.push($scope.navigationItemMatching('Me', '/#/profile'))

      items.push($scope.navigationItemMatching('Community', '/#/community'))
      items.push($scope.navigationItemMatching('Parents', '/#/parents'))
      $scope.rebuildNavigationClasses(items)
      return items

    if side == 'right'
      if Auth.user()
        items.push($scope.navigationItemMatching('Sign Out', '/#/sign-out'))
      else
        items.push($scope.navigationItemMatching('Create Account', '/#/sign-up'))
        items.push($scope.navigationItemMatching('Sign In', '/#/sign-in'))
      $scope.rebuildNavigationClasses(items)
      return items


  $scope.startTour = () ->
    if $cookieStore.get('tutorial')
      if confirm("You've already started the tutorial. Do you want to continue where you left off?")
        return $scope.openTour()

    req = $http({method: 'POST', url:'/api/v0/worlds/52301d357eebf50000000001/clone'})
    req.success (data, status, headers, config) ->
      if status != 200
        return alert('Sorry, the tutorial world doesn\'t seem to exist.')
      $cookieStore.put('tutorial', "#{data.world_id}:#{data.stage_id}")
      $scope.openTour()

    req.error (data, status, headers, config) ->
      alert(data)


  $scope.openTour = () ->
    tutorial = $cookieStore.get('tutorial')
    return $scope.startTour() unless tutorial
    tutorial = tutorial.split(':')
    window.location.href = "/stage-editor/#/#{tutorial[0]}/#{tutorial[1]}"


@NavCtrl.$inject = ['$scope', '$location', 'Auth', '$http', '$cookieStore']
