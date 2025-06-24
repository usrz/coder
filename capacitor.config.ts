import type { CapacitorConfig } from '@capacitor/cli'

const config: CapacitorConfig = {
  appId: 'com.usrz.coder',
  appName: 'Coder',
  webDir: 'public',
  ios: {
    contentInset: 'always',
    backgroundColor: '#181818',
  },
  server: {
    url: 'https://code-server.usrz.com/?ew=true',
    allowNavigation: [
      'code-server.usrz.com',
      '*.cloudflareaccess.com',
      '*.google.com',
    ],
  },
}

export default config
