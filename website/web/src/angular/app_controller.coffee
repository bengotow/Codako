@AppCtrl = ($scope, $dialog, $location, Users, Stages, Comments, Auth, $http) ->
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
      if $location.$$path.indexOf(item.href) != -1
        item.class = 'active'
      else
        item.class = ''


  $scope.navigation = (side) ->
    items = []

    if side == 'left'
      if Auth.user()
        items.push($scope.navigationItemMatching('My Worlds', 'worlds'))

      items.push($scope.navigationItemMatching('Home', 'home'))
      items.push($scope.navigationItemMatching('Community', 'community'))
      items.push($scope.navigationItemMatching('Parents', 'parents'))
      $scope.rebuildNavigationClasses(items)
      return items

    if side == 'right'
      if Auth.user()
        items.push($scope.navigationItemMatching('Sign Out', 'sign-out'))
      else
        items.push($scope.navigationItemMatching('Create Account', 'sign-up'))
        items.push($scope.navigationItemMatching('Sign In', 'sign-in'))
      $scope.rebuildNavigationClasses(items)
      return items


@AppCtrl.$inject = ['$scope', '$dialog','$location', 'Users', 'Stages', 'Comments', 'Auth', '$http']
