` tweet.ink, program to send tweets `

` standard libraries `
std := load('std')
str := load('str')
json := load('json')

` hmac-sha1 signing `
hmac := load('hmac')

f := std.format
log := std.log
hex := std.hex
xeh := std.xeh
map := std.map
cat := std.cat
slice := std.slice
upper := str.upper
ser := json.ser

CONSUMERKEY := '<consumer api key>'
CONSUMERSECRET := '<consumer api secret>'
OAUTHTOKEN := '<oauth public key>'
OAUTHSECRET := '<oauth private key>'

` generate a unique nonce for use with OAuth `
nonce := () => (
	piece := () => (std.hex)(10000000000 * rand())
	piece() + piece() + piece() + piece()
)

` OAuth authorization header needs to be percent-encoded `
percentEncodeChar := c => (
	` should it be encoded? `
	p := point(c)
	isValidPunct := (c = '.') | (c = '_') | (c = '-') | (c = '~')

	` is numeric, or uppercase ASCII, or lowercase ASCII, or a valid punct `
	(p > 47 & p < 58) | (p > 64 & p < 91) | (p > 96 & p < 123) | isValidPunct :: {
		true -> c
		false -> '%' + upper(hex(p))
	}
)
percentEncode := piece => cat(map(piece, percentEncodeChar), '')

` converting from hex (from HMAC) to base64 `
char64 := n => 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'.(n)
xxxTo64 := xxx => len(xxx) :: {
	` 4 padding bits, 2 padding =s `
	2 -> (
		first := floor(xeh(xxx.0 + xxx.1) / 4)
		second := (xeh(xxx.1) % 4) * 16
		char64(first) + char64(second) + '=='
	)
	` 2 padding bits, 1 padding = `
	4 -> (
		first := floor(xeh(xxx.0 + xxx.1) / 4)
		second := ((xeh(xxx.1) % 4) * 16) + xeh(xxx.2)
		third := xeh(xxx.3) * 4
		char64(first) + char64(second) + char64(third) + '='
	)
	` no padding bits, no padding =s `
	6 -> (
		first := floor(xeh(xxx.0 + xxx.1) / 4)
		second := ((xeh(xxx.1) % 4) * 16) + xeh(xxx.2)
		third := xeh(xxx.3) * 4 + floor(xeh(xxx.4) / 4)
		fourth := (xeh(xxx.4) % 4) * 16 + xeh(xxx.5)
		char64(first) + char64(second) + char64(third) + char64(fourth)
	)
}
base64Encode := inHex => (sub := (result, inHex) => len(inHex) :: {
	0 -> result
	_ -> sub(
		result + xxxTo64(slice(inHex, 0, 6))
		slice(inHex, 6, len(inHex))
	)
})('', inHex)

send := status => (
	` generate all variables `
	nonceStr := nonce()
	timestamp := string(floor(time()))

	` generate an OAuth signature for the status update request `
	paramString := cat([
		'oauth_consumer_key=' + percentEncode(CONSUMERKEY)
		'oauth_nonce=' + percentEncode(nonceStr)
		'oauth_signature_method=HMAC-SHA1'
		'oauth_timestamp=' + timestamp
		'oauth_token=' + percentEncode(OAUTHTOKEN)
		'oauth_version=1.0'
		'status=' + percentEncode(status)
	], '&')
	base := cat([
		'POST'
		percentEncode('https://api.twitter.com/1.1/statuses/update.json')
		percentEncode(paramString)
	], '&')
	signingKey := percentEncode(CONSUMERSECRET) + '&' + percentEncode(OAUTHSECRET)
	signature := base64Encode((hmac.sha1)(base, signingKey))

	` add the signature to the header `
	oauthParams := [
		'oauth_consumer_key="' + percentEncode(CONSUMERKEY) + '"'
		'oauth_nonce="' + percentEncode(nonceStr) + '"'
		'oauth_signature="' + percentEncode(signature) + '"'
		'oauth_signature_method="HMAC-SHA1"'
		'oauth_timestamp="' + timestamp + '"'
		'oauth_token="' + percentEncode(OAUTHTOKEN) + '"'
		'oauth_version="1.0"'
	]

	` make a request to Twitter API `
	req({
		method: 'POST'
		url: 'https://api.twitter.com/1.1/statuses/update.json?status=' + percentEncode(status)
		headers: {
			Authorization: 'OAuth ' + (cat(oauthParams, ', '))
		}
	}, d => log(d.data.body))
)

send('Tweet sent with Ink, ' + string(floor(time())))
