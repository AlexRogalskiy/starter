package com.c4_soft.starter.proxies.security;

import java.util.Collection;
import java.util.Collections;
import java.util.HashSet;
import java.util.Map;
import java.util.Optional;
import java.util.Set;

import com.c4_soft.springaddons.security.oauth2.oidc.OidcToken;

public class CustomOidcToken extends OidcToken {
	private static final long serialVersionUID = -958466786321575604L;

	public CustomOidcToken(Map<String, Object> claims) {
		super(claims);
	}

	@SuppressWarnings("unchecked")
	public Set<Long> getGrantIdsOnBehalfOf(String proxiedUserSubject) {
		return Optional
				.ofNullable(getClaimAsMap("proxies"))
				.flatMap(map -> Optional.ofNullable((Collection<Long>) map.get(proxiedUserSubject)))
				.map(HashSet::new)
				.map(Collections::unmodifiableSet)
				.orElse(Collections.emptySet());
	}
}
