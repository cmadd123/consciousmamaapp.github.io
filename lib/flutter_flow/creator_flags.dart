/// Feature flags for where creator functionality lives.
///
/// Creator *authoring* (publishing meal plans, toggling "share with
/// followers" on recipes/routines/templates, building collections) is being
/// consolidated onto the web dashboard (creator/index.html). Followers still
/// consume shared content in the app — only the authoring controls are hidden.
///
/// Flip this to `true` to bring in-app creator authoring back.
const bool kCreatorAuthoringInApp = false;
