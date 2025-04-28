class MeanderingRoute {
  const MeanderingRoute({
    required this.path,
    required this.name,
  });

  final String path;
  final String name;
}

const splashRoute = MeanderingRoute(
  name: 'splash',
  path: '/splash',
);

const homeRoute = MeanderingRoute(
  name: 'home',
  path: '/',
);

const loginRoute = MeanderingRoute(
  name: 'login',
  path: '/login',
);

const signUpRoute = MeanderingRoute(
  name: 'signup',
  path: '/signup',
);

const accountRoute = MeanderingRoute(
  name: 'account  ',
  path: '/account',
);