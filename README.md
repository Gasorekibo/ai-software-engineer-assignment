# AI Software Engineer Assignment

An `HttpClient` implementation in TypeScript that automatically manages OAuth2 Bearer tokens — refreshing them when they are missing, expired, or in an invalid state.

## How it works

When `request()` is called with `api: true`, the client checks whether the current token is valid before making the request. If the token is `null`, not a proper `OAuth2Token` instance, or expired, it automatically refreshes it. The resulting `Authorization: Bearer <token>` header is then attached to the request.

## Prerequisites

- [Node.js](https://nodejs.org/) v18+ and npm
- [Docker](https://www.docker.com/) (optional, for containerized test runs)

## Running Tests

### Locally

```bash
npm install
npm run test
```

To run in watch mode (re-runs on file changes):

```bash
npm run test:watch
```

### With Docker

```bash
# Build the image
docker build -t ai-software-engineer .

# Run the tests (container exits after tests complete)
docker run --rm ai-software-engineer
```

## Project Structure

```
.
├── src/
│   ├── httpClient.ts        # HttpClient class with OAuth2 token refresh logic
│   └── tokens.ts            # OAuth2Token class (stores token, checks expiry)
├── tests/
│   └── httpClient.test.ts   # Test suite covering all token refresh scenarios
├── Dockerfile               # Containerized test runner
├── tsconfig.json            # TypeScript configuration
└── package.json             # Dependencies and npm scripts
```
