import { LogLevel, OpenIdConfiguration } from "angular-auth-oidc-client";

const openIdConfiguration: OpenIdConfiguration = {
  // https://github.com/damienbod/angular-auth-oidc-client/blob/master/docs/configuration.md
  clientId: 'starter',
  forbiddenRoute: '/settings',
  eagerLoadAuthWellKnownEndpoints: false,
  ignoreNonceAfterRefresh: true, // Keycloak sends refresh_token with nonce
  logLevel: LogLevel.Warn,
  postLogoutRedirectUri: 'https://bravo-ch4mp:8100',
  redirectUrl: 'https://bravo-ch4mp:8100',
  renewTimeBeforeTokenExpiresInSeconds: 60,
  responseType: 'code',
  scope: 'email openid offline_access roles',
  silentRenew: true,
  useRefreshToken: true,
  stsServer: 'https://bravo-ch4mp:9443/auth/realms/master',
  unauthorizedRoute: '/settings',
};

export const environment = {
  production: true,
  householdsApiBasePath: 'https://bravo-ch4mp:4210',
  openIdConfiguration,
};
