@SignInCtrl = ($scope, $location, $dialog, Users, Stages, Comments, Auth, $http) ->
	$scope.credentials = {nickname:'', password:''}
	$scope.registration = {nickname:'', password:'', password_confirm:'', nickname:'', terms_agreement: false}

	if $location.path() == '/sign-out'
		Auth.clearCredentials()
		$location.path('/sign-in')

	Auth.withUser (error, user) ->
		$location.path('/profile') if user


	$scope.signUp = () ->
		data = _.clone($scope.registration)
		data.password = CryptoJS.MD5(data.password)

		Users.create data, (user) ->
			alert(JSON.stringify(user))


	$scope.signIn = () ->
		Auth.setCredentials($scope.credentials.nickname, CryptoJS.MD5($scope.credentials.password))
		Auth.withUser (error, user) ->
			return alert(error) if (error)
			$location.path('/profile')


@SignInCtrl.$inject = ['$scope', '$location', '$dialog', 'Users', 'Stages', 'Comments', 'Auth', '$http']
