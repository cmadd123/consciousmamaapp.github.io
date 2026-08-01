/// Feature flags for where creator functionality lives.
///
/// Creator *authoring* (publishing meal plans, toggling "share with
/// followers" on recipes/routines/templates, building collections) is being
/// consolidated onto the web dashboard (creator/index.html). Followers still
/// consume shared content in the app — only the authoring controls are hidden.
///
/// Sharing/authoring is done ONLY on the web dashboard. In the app, shared
/// items show a read-only "people" indicator (see below) but cannot be
/// toggled. Keep this false.
const bool kCreatorAuthoringInApp = false;
