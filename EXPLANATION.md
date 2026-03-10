# Bug Explanation

## What was the bug?

`HttpClient.request()` failed to refresh the OAuth2 token when `oauth2Token` held a plain object (e.g., `{ accessToken: "stale", expiresAt: 0 }`) instead of an `OAuth2Token` instance. As a result, API requests were sent without an `Authorization` header.

## Why did it happen?

The original refresh condition covered only two cases:

```typescript
if (
  !this.oauth2Token ||
  (this.oauth2Token instanceof OAuth2Token && this.oauth2Token.expired)
) {
  this.refreshOAuth2();
}
```

| Condition | Triggers refresh when… |
|---|---|
| `!this.oauth2Token` | Token is `null` or `undefined` |
| `instanceof OAuth2Token && expired` | Token is a valid instance **and** it has expired |

When `oauth2Token` was a plain object, both conditions evaluated to `false`:

- `!this.oauth2Token` → `false` — the object is truthy
- `instanceof OAuth2Token && ...` → `false` — a plain object is not an `OAuth2Token` instance

So `refreshOAuth2()` was never called, and the subsequent `instanceof` guard that sets the header also failed, leaving the request without any `Authorization` header.

## Why does the fix solve it?

The fix adds a third condition that explicitly catches non-`OAuth2Token` values:

```typescript
if (
  !this.oauth2Token ||
  !(this.oauth2Token instanceof OAuth2Token) ||
  this.oauth2Token.expired
) {
  this.refreshOAuth2();
}
```

| Condition | Triggers refresh when… |
|---|---|
| `!this.oauth2Token` | Token is `null` or `undefined` |
| `!(instanceof OAuth2Token)` | Token exists but is not a proper `OAuth2Token` instance (e.g., a plain object) |
| `expired` | Token is a valid instance but has expired |

Now a plain object triggers the second condition, `refreshOAuth2()` is called, a real `OAuth2Token` is created, and the `Authorization` header is correctly set.

## Known limitation

If multiple API requests are fired simultaneously while the token is invalid, each one independently detects the bad token and calls `refreshOAuth2()`. Since the current implementation is synchronous and in-memory this is harmless, but in a real application with an asynchronous token endpoint this could cause duplicate refresh requests. A common solution is to store the in-flight refresh as a `Promise` and have concurrent requests await the same one.
