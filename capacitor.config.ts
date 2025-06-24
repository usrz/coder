import type { CapacitorConfig } from '@capacitor/cli'
import 'dotenv/config'

/* Easy configuration via ".env" file */
const codeServerUrl = process.env.CODE_SERVER_URL || 'https://code-server.usrz.com/'
const applicationId = process.env.APPLICATION_ID || 'com.usrz.coder'
const applicationName = process.env.APPLICATION_NAME || 'Coder'

/* Validate and mangle the URL */
const url = new URL(codeServerUrl)
url.searchParams.set('ew', 'true')

const config: CapacitorConfig = {
  /* The App ID: if you want TestFlight, change this! */
  appId: applicationId,
  /* The name of the app as shown in the dock */
  appName: applicationName,
  /* Root directory of our web assets */
  webDir: 'public',
  /* IOS support */
  ios: {
    /* Make sure WKWebView stays within the insets */
    contentInset: 'always',
    /* I like the standard VSCode dark theme */
    backgroundColor: '#181818',
  },
  server: {
    /* This is the server hosting the code-server instance */
    url: url.href,
    /* Allow navigation to these domains:
     * - code-server.usrz.com: the code-server instance
     * - *.cloudflareaccess.com: the Cloudflare Access login page
     * - *.google.com: the Google login page for Google SSO via Cloudflare
     */
    allowNavigation: [
      url.hostname,
      '*.cloudflareaccess.com',
      '*.google.com',
    ],
  },
}

export default config
