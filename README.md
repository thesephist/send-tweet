# send-tweet 🐦

`send-tweet` is a repository for a small [Ink](https://github.com/thesephist/ink) program to send Tweets using the Twitter JSON API. This project also required Ink libraries for SHA1 and HMAC-SHA1 algorithms, percent-encoding URI strings, and base64 conversion, which are also included as library functions in the project.

## Authorization

For the send-tweet functionality to work, you'll need to (1) be registered as a Twitter developer application, and (2) have the requisite OAuth 1.0 tokens to authenticate as a given user. You'll need four keys to place inside `tweet.ink`:

- `CONSUMERKEY`: The public key portion of the Twitter API token
- `CONSUMERSECRET`: The private key portion of the Twitter API token
- `OAUTHTOKEN`: OAuth public key
- `OAUTHSECRET`: OAuth secret / private key

You can generate and find these keys at `developer.twitter.com`.

## Usage

You can call the program with `ink tweet.ink` if you have Ink installed. If not, you can install or download the binary at [github.com/thesephist/ink](https://github.com/thesephist/ink).
