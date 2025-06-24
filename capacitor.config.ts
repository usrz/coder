import type { CapacitorConfig } from '@capacitor/cli'

const config: CapacitorConfig = {
  /* The App ID: if you want TestFlight, change this! */
  appId: 'com.usrz.coder',
  /* The name of the app as shown in the dock */
  appName: 'Coder',
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
    url: 'https://code-server.usrz.com/?ew=true',
    /* Allow navigation to these domains:
     * - code-server.usrz.com: the code-server instance
     * - *.cloudflareaccess.com: the Cloudflare Access login page
     * - *.google.com: the Google login page for Google SSO via Cloudflare
     */
    allowNavigation: [
      'code-server.usrz.com',
      '*.cloudflareaccess.com',
      '*.google.com',
    ],
  },
}

export default config
