// Load chrome/userChrome.css from the profile.
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
// Keep the transparent background when the window is not focused.
user_pref("zen.view.grey-out-inactive-windows", false);
// macOS vibrancy is Zen's only window transparency; without it the window is opaque.
user_pref("zen.widget.macos.window-vibrancy", true);
