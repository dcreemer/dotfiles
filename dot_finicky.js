module.exports = {
    defaultBrowser: "Safari",
    handlers: [
      {
        match: finicky.matchHostnames("docs.google.com"),
        browser: "Google Chrome"
      },
      {
        match: finicky.matchHostnames(["tailscale.com", "login.tailscale.com"]),
        browser: "Google Chrome"
      },
      {
        match: /^https?:\/\/([a-z0-9]+\.)?zoom\.us\/j\/.*$/,
        browser: "us.zoom.xos"
      },
      {
        match: /^https?:\/\/quip\-a....\.com\/.*$/,
        browser: [ "Safari", "com.quip.Desktop" ]
      },
      {
        match: /^https?:\/\/.*apple\.com\/.*$/,
        browser: "Safari"
      },
      {
        match: /^https?:\/\/.*applesurveys\.com\/.*$/,
        browser: "Safari"
      },
      {
        match: /^https?:\/\/.*benevity\.org\/.*$/,
        browser: "Safari"
      },
      {
        match: /^https?:\/\/.*box\.com\/.*$/,
        browser: "Safari"
      },
      {
        match: /^https?:\/\/.*webex\.com\/.*$/,
        browser: "Safari"
      },
      {
        match: /^https?:\/\/.*icloud\.com\/.*$/,
        browser: "Safari"
      },
      {
        match: /^https?:\/\/.*slack\.com\/.*$/,
        browser: "Safari"
      },
      {
        match: /^https?:\/\/.*coderpad\.io\/.*$/,
        browser: "Safari"
      },
      {
        match: /^https?:\/\/.*inc\.newsweaver\.com\/app.*$/,
        browser: "Safari"
      },
      {
        match: /^https?:\/\/.*workday\.com\/.*$/,
        browser: "Safari"
      },
      {
        match: /^https?:\/\/.*\.live\.com\/.*$/,
        browser: "Microsoft Edge"
      },
      {
        match: /^https?:\/\/.*\.microsoft\.com\/.*$/,
        browser: "Microsoft Edge"
      },
      {
        match: /^https?:\/\/.*\.bing\.com\/.*$/,
        browser: "Microsoft Edge"
      },
    ]
  }
