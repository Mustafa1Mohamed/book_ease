function withSupabaseAuthenticatedRole(existingClaims) {
  return {
    ...(existingClaims ?? {}),
    role: 'authenticated',
  };
}

module.exports = { withSupabaseAuthenticatedRole };
