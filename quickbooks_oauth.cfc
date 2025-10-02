component {

    this.client_id = "YOUR_CLIENT_ID";
    this.client_secret = "YOUR_CLIENT_SECRET";
    this.redirect_uri = "https://yourdomain.com/callback.cfm";

    this.authEndpoint = "https://appcenter.intuit.com/connect/oauth2";
    this.accessTokenEndpoint = "https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer";
    this.scope = "com.intuit.quickbooks.accounting";

    /**
     * Generate OAuth2 Authorization URL
     */
    public string function getAuthURL() {
        var state = createUUID(); // CSRF protection
        var url = this.authEndpoint & "?" &
                  "client_id=" & this.client_id &
                  "&response_type=code" &
                  "&scope=" & this.scope &
                  "&redirect_uri=" & encodeForURL(this.redirect_uri) &
                  "&state=" & state;

        session.oauth_state = state;
        return url;
    }

    /**
     * Exchange authorization code for access token
     */
    public struct function getAccessToken(required string code) {
        var result = {};
        var httpService = new http();
        httpService.setMethod("POST");
        httpService.setUrl(this.accessTokenEndpoint);
        httpService.addParam(type="header", name="Content-Type", value="application/x-www-form-urlencoded");
        httpService.addParam(type="header", name="Accept", value="application/json");

        var body = "grant_type=authorization_code" &
                   "&code=" & code &
                   "&redirect_uri=" & encodeForURL(this.redirect_uri);

        httpService.addParam(type="body", value=body);

        httpService.setUsername(this.client_id);
        httpService.setPassword(this.client_secret);

        var response = httpService.send().getPrefix();

        if (response.statusCode eq 200) {
            result = deserializeJSON(response.fileContent);
        } else {
            result.error = response.fileContent;
        }

        return result;
    }

    /**
     * Refresh access token
     */
    public struct function refreshAccessToken(required string refreshToken) {
        var result = {};
        var httpService = new http();
        httpService.setMethod("POST");
        httpService.setUrl(this.accessTokenEndpoint);
        httpService.addParam(type="header", name="Content-Type", value="application/x-www-form-urlencoded");
        httpService.addParam(type="header", name="Accept", value="application/json");

        var body = "grant_type=refresh_token" &
                   "&refresh_token=" & refreshToken;

        httpService.addParam(type="body", value=body);

        httpService.setUsername(this.client_id);
        httpService.setPassword(this.client_secret);

        var response = httpService.send().getPrefix();

        if (response.statusCode eq 200) {
            result = deserializeJSON(response.fileContent);
        } else {
            result.error = response.fileContent;
        }

        return result;
    }

}
