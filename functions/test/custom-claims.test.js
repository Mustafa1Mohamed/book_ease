const assert = require('node:assert/strict');
const test = require('node:test');

const {
  withSupabaseAuthenticatedRole,
} = require('../src/custom-claims');

test('preserves existing claims and assigns the Supabase role', () => {
  assert.deepEqual(
    withSupabaseAuthenticatedRole({
      department: 'cardiology',
      role: 'legacy-role',
      verified: true,
    }),
    {
      department: 'cardiology',
      role: 'authenticated',
      verified: true,
    },
  );
});

test('handles a user with no existing custom claims', () => {
  assert.deepEqual(withSupabaseAuthenticatedRole(undefined), {
    role: 'authenticated',
  });
});
