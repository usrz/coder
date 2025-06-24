# Coder: Because I Wasn't Allowed to Bring My Laptop

This project was born out of desperation and determination. You see, my wife
*forbade* me from taking my laptop on our four-week vacation to Japan. Fair
enough - vacation is vacation. But I'm a hopeless nerd, and going four weeks
without writing code? Yeah, no chance.

The compromise? I was allowed to bring my iPad.

The solution? Build something that lets me code *properly* on it.

Lately I've been playing around with [Coder](https://coder.com/)'s
[code-server](https://github.com/coder/code-server), which is essentially VS
Code running in the browser - a great idea in theory, but... let's be honest:
mobile Safari is not exactly a dream coding experience.

I also work a lot with [Capacitor](https://capacitorjs.com/) at my day job, so
one late night I thought:

> Why not wrap code-server inside a proper iPad app using Capacitor and fix
> everything that annoys me?

And that's exactly what this is.

## 💡 What It Does

- Wraps `code-server` in a native iPad app using Capacitor
- Supports **Stage Manager** with multiple windows (yes, you can open two
  projects side-by-side!)
- Handles **keyboard shortcuts properly**, so your usual VS Code muscle memory
  still works
- Supports **external monitor setup** - plug in a screen, grab your keyboard,
  and you're basically back in dev mode
- Sends keystrokes straight to the WebView - no remapping nonsense
- Works surprisingly well

## 🔧 Server Setup Notes

What I didn't mention yet: I already have a `code-server` instance up and
running - it's hosted on AWS, proxied through Cloudflare, and secured with
**Cloudflare Access** for authentication. So, yes, it's safe and sane. Proper
TLS certificates are in place, so you won't run into any annoying security
warnings or mixed content errors.

If you're reading the source and wondering "where do I plug in my server URL?",
check the `capacitor.config.ts` file. You'll see the relevant environment
variables and setup spots in there.

## 🚧 Why This Exists

I wanted something that felt like _real_ VS Code on iPad - not just a WebView
in disguise, but something that understood:

- Developers don't want to touch the screen every 5 seconds
- iPadOS can do real multitasking - if you help it
- Coding while traveling shouldn't be a pain

This is not a product. It's a proof of concept.

It might break. It might work perfectly. But it's here.
