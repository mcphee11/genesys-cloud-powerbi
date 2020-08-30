//This example was build in support with the project:https://github.com/plasne/PowerBI-OAuthToSQL/blob/master/OAuthToSQL.pq 
// as well as Microsoft Documentation online.
//
//This is designed as a Example ONLY on how you can sue PowerBi connectors to connect to Genesys Cloud


// This file contains your Data Connector logic
section Genesys_Cloud;

// oauth details
client_id = Text.FromBinary(Extension.Contents("client_id.env")); //you need to add your client_id.env file to the project
client_secret = Text.FromBinary(Extension.Contents("client_secret.env")); //you need to add your client_secret.env file to the project
token_uri = "https://login.mypurecloud.com.au/oauth/token"; //Set to your ORG region eg: mypurecloud.com or mypurecloud.jp
authorize_uri = "https://login.mypurecloud.com.au/oauth/authorize"; //Set to your ORG region eg: mypurecloud.com or mypurecloud.jp
logout_uri = "https://login.microsoftonline.com/logout.srf";
redirect_uri = "https://oauth.powerbi.com/views/oauthredirect.html";

StartLogin = (resourceUrl, state, display) =>
    let
        authorizeUrl = authorize_uri & "?" & Uri.BuildQueryString([
            client_id = client_id,  
            redirect_uri = redirect_uri,
            state = state,
            response_type = "code",
            response_mode = "query",
            login = "login"
        ])
    in
        [
            LoginUri = authorizeUrl,
            CallbackUri = redirect_uri,
            WindowHeight = 720,
            WindowWidth = 1024,
            Context = null
        ];

FinishLogin = (context, callbackUri, state) =>
    let
        parts = Uri.Parts(callbackUri)[Query],
        result = if (Record.HasFields(parts, {"error", "error_description"})) then 
                    error Error.Record(parts[error], parts[error_description], parts)
                 else
                    TokenMethod("authorization_code", "code", parts[code])
    in
        result;

// Called when the access_token has expired, and a refresh_token is available.
Refresh = (resourceUrl, refresh_token) => TokenMethod("refresh_token", "refresh_token", refresh_token);

Logout = (token) => logout_uri;

// grantType:  Maps to the "grant_type" query parameter.
// tokenField: The name of the query parameter to pass in the code.
// code:       Is the actual code (authorization_code or refresh_token) to send to the service.
TokenMethod = (grantType, tokenField, code) =>
    let
        queryString = [
            client_id = client_id,
            client_secret = client_secret,
            grant_type = grantType,
            redirect_uri = redirect_uri
        ],
        queryWithCode = Record.AddField(queryString, tokenField, code),

        tokenResponse = Web.Contents(token_uri, [
            Content = Text.ToBinary(Uri.BuildQueryString(queryWithCode)),
            Headers = [
                #"Content-type" = "application/x-www-form-urlencoded",
                #"Accept" = "application/json"
            ],
            ManualStatusHandling = {400} 
        ]),
        body = Json.Document(tokenResponse),
        result = if (Record.HasFields(body, {"error", "error_description"})) then 
                    error Error.Record(body[error], body[error_description], body)
                 else
                    body
    in
        result;

[DataSource.Kind="Genesys_Cloud", Publish="Genesys_Cloud.Publish"]    
shared Genesys_Cloud.Contents = (url as text, optional method as text, optional body as text)=>

    //now supports POST and defaults to GET if not used. Body needs to be in JSON format.
    let
        source = if(method = "POST") then Web.Contents(url, [Headers = [#"Content-Type"="application/json"], Content = Text.ToBinary(body)])
        else  Web.Contents(url),
        json = Json.Document(source)     
    in
        json;

// Data Source Kind description
Genesys_Cloud = [
    Authentication = [
        OAuth = [
        StartLogin=StartLogin,
        FinishLogin=FinishLogin,
        Refresh=Refresh,
        Logout=Logout
        ]
    ],
    Label = Extension.LoadString("DataSourceLabel")
];

// Data Source UI publishing description
Genesys_Cloud.Publish = [
    Beta = true,
    Category = "Other",
    ButtonText = { Extension.LoadString("ButtonTitle"), Extension.LoadString("ButtonHelp") },
    LearnMoreUrl = "https://powerbi.microsoft.com/",
    SourceImage = Genesys_Cloud.Icons,
    SourceTypeImage = Genesys_Cloud.Icons
];

Genesys_Cloud.Icons = [
    Icon16 = { Extension.Contents("Image16.png"), Extension.Contents("Image20.png"), Extension.Contents("Image24.png"), Extension.Contents("Image32.png") },
    Icon32 = { Extension.Contents("Image32.png"), Extension.Contents("Image40.png"), Extension.Contents("Image48.png"), Extension.Contents("Image64.png") }
];
