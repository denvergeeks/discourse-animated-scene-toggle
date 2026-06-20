# Animated Scene Color Toggle

A Discourse **theme component** that adds an animated dark/light mode toggle to the header using Discourse core color mode behavior, with the visual scene rendered from an asset-backed exact SVG/HTML port.

## Why this architecture
- Uses the supported `api.headerIcons.add(...)` header integration path.
- Ships as a **theme component**, which is the correct vehicle for a frontend-only header customization.
- Keeps the large pasted scene in `assets/animated-scene.html` instead of forcing it through the GJS parser.
- Avoids `modifyClass`, template overrides, and brittle DOM patching.

## Features
- Animated header toggle UI backed by the pasted scene asset.
- Uses Discourse core dark/light behavior instead of inventing separate theme state.
- Hardened asset URL resolution for remote theme installs.
- Optional debug mode for asset loading diagnostics.
- Visible fallback indicator when the asset iframe fails to load.

## Repository layout
```text
about.json
settings.yml
common/common.scss
locales/en.yml
assets/animated-scene.html
javascripts/discourse/api-initializers/animated-scene-toggle.gjs
javascripts/discourse/components/animated-scene-toggle.gjs
screenshots/light.png
screenshots/dark.png
```

## Install
### Remote Git install
1. Go to `Admin > Appearance > Themes & components`.
2. Open the `Components` tab.
3. Click `Install`.
4. Choose `From a Git repository`.
5. Paste this repository URL.
6. Install the component.
7. Attach it to your active theme.

Discourse supports remote Git repositories for themes and theme components, and that is the recommended path for complex reusable components. [Replace this README line with your real repository URL after publishing.]

### Private repository
If the repository is private, install it with the private Git repository workflow and add the generated deploy key to your Git host before finishing setup.

## Settings
- `toggle_before_icon` — insert before a specific header icon key.
- `show_for_anons` — show for anonymous visitors.
- `compact_mode` — smaller control footprint.
- `debug_mode` — show asset loading diagnostics.

## Asset resolution order
1. `settings.theme_uploads_local.animated_scene_html`
2. `settings.theme_uploads.animated_scene_html`
3. `settings.animated_scene_html`
4. `/assets/animated-scene.html`

## Development
### Using the Discourse Theme CLI
1. Install the CLI: `gem install discourse_theme`
2. Create or clone this repository locally.
3. Run the watcher against your target Discourse instance.
4. Develop locally and commit changes to Git.

Discourse’s remote-theme workflow is designed around Git-backed development, with the CLI available for local sync during active development.

## Screenshots
The repository includes placeholder screenshot files so `about.json` has a valid GitHub-ready structure. Replace them with real component previews before release.

Recommended screenshot notes:
- Put screenshots in the root `screenshots/` directory.
- Keep to two files max.
- Use light and dark previews.
- Keep each image under 1 MB.

## Upgrade notes
- `api.headerIcons.add(...)` is the key supported extension point here.
- The remaining watchpoint is the exact client-side color-scheme setter surface in core.
- The iframe wrapper is intentionally conservative and parser-safe.

## Release checklist
- [ ] Replace placeholder screenshots with real images.
- [ ] Set the final GitHub repository URL in this README.
- [ ] Replace `authors` in `about.json` if needed.
- [ ] Verify install from a remote Git repository on a clean test forum.
- [ ] Verify anonymous and logged-in behavior.
- [ ] Verify light and dark switching on desktop and mobile.
- [ ] Verify iframe asset URL resolution on your production host.
- [ ] Confirm fallback UI appears when the asset path is intentionally broken.
- [ ] Confirm `debug_mode` text is hidden in normal production use.
- [ ] Add a Meta support topic URL if you publish one.

## License
MIT link is declared in `about.json`. Replace with a repository `LICENSE` file URL if you want a stricter GitHub-ready metadata setup.
