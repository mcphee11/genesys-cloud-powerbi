# genesys-cloud-powerbi
Microsoft Power Bi connector to Genesys Cloud Analytics API Example

This current example uses "Authorization code" grant to OAuth2 to your Genesys Cloud ORG environment. The first thing you will need to do is to get a ClientID and Secret for this OAuth2 type from your Genesys Cloud ORG with the ability to connect to the API endpoint you require for example the Scope of Analytics or Users. This will also need to have a redirect to the Microsoft url: "https://oauth.powerbi.com/views/oauthredirect.html"

![](/docs/images/screenShot1.png?raw=true)

You will then need to configure the "client_id" & "client_secret" to your own as well as the ORG location. In my example im based in Australia so i have used "mypurecloud.com.au" if your in a different region this will need to be changed.

![](/docs/images/screenShot2.png?raw=true)

Once you have saved and done a build on the project get the "Genesys_Cloud.mez" file from the project bin DIR and put it into a folder on your PC "C:\Users\\{user}\Documents\Power BI Desktop\Custom Connectors" This is where Power Bi will look for the custom connectors.

In the Power Bi client options you will need to "Allow any extension to load" to do this go inside the options and enable this under security. NOTE this connector is not published and run at your own risk.

![](/docs/images/screenShot3.png?raw=true)

To conenct to the new connector in PowerBi so to "GetData" under "Other" you will see the new "Genesys_Cloud" connector that you can use.

![](/docs/images/screenShot4.png?raw=true)

You will get a 3rd party warning. Then the connector will ask you for the url input that you want to connect to. (NOTE in this first code PUSH only GET is supported, im yet to add support for other methods) enter a endpoint in full for example "https://api.mypurecloud.com.au/api/v2/users". You will then need to sign in.

![](/docs/images/screenShot5.png?raw=true)

This will redirect you to a OAuth login screen provided by Genesys Cloud. If you are already logged in then it will automaticlly use this token if valid.

Once you have built out the query you wish to use with the nested JSON objects in your query you can click on "Advanced Editor" to look at the query and use this inside your code to build this detail out automaticly. Or if you prefer you can build this query yourself directly then use it in the code.

![](/docs/images/screenShot6.png?raw=true)