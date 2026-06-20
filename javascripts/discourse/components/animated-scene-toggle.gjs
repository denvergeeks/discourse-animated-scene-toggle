import Component from "@glimmer/component";
import { inject as service } from "@ember/service";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { schedule } from "@ember/runloop";
import DButton from "discourse/components/d-button";
import I18n from "discourse-i18n";

export default class AnimatedSceneToggle extends Component {
  @service currentUser;
  @service themeSelector;

  @tracked isLightMode = false;
  @tracked frameLoaded = false;
  @tracked frameFailed = false;
  iframeElement = null;
  loadTimeout = null;

  constructor() {
    super(...arguments);
    this.syncState();
    this.observeRootThemeChanges();
  }

  willDestroy() {
    super.willDestroy(...arguments);
    this._observer?.disconnect();
    if (this.loadTimeout) {
      clearTimeout(this.loadTimeout);
    }
  }

  get shouldRender() {
    return settings.show_for_anons || !!this.currentUser;
  }

  get buttonClass() {
    const classes = ["animated-scene-toggle-header-button"];
    classes.push(this.isLightMode ? "light-mode" : "dark-mode");

    if (settings.compact_mode) {
      classes.push("is-compact");
    }

    if (this.frameFailed) {
      classes.push("has-frame-failure");
    }

    if (this.frameLoaded) {
      classes.push("is-frame-ready");
    }

    return classes.join(" ");
  }

  get title() {
    return this.isLightMode
      ? I18n.t(themePrefix("animated_scene_toggle.switch_to_dark"))
      : I18n.t(themePrefix("animated_scene_toggle.switch_to_light"));
  }

  get debugMode() {
    return settings.debug_mode;
  }

  get debugText() {
    if (!this.debugMode) {
      return null;
    }

    if (this.frameFailed) {
      return I18n.t(themePrefix("animated_scene_toggle.asset_failed"));
    }

    if (this.frameLoaded) {
      return I18n.t(themePrefix("animated_scene_toggle.asset_ready"));
    }

    return I18n.t(themePrefix("animated_scene_toggle.asset_loading"));
  }

  get sceneUrl() {
    return (
      settings.theme_uploads_local?.animated_scene_html ||
      settings.theme_uploads?.animated_scene_html ||
      settings.animated_scene_html ||
      "/assets/animated-scene.html"
    );
  }

  syncState() {
    const root = document.documentElement;
    this.isLightMode =
      !root.classList.contains("dark") &&
      root.dataset.themeColorScheme !== "dark";

    schedule("afterRender", this, this.postModeToFrame);
  }

  observeRootThemeChanges() {
    if (this._observer) {
      return;
    }

    this._observer = new MutationObserver(() => this.syncState());
    this._observer.observe(document.documentElement, {
      attributes: true,
      attributeFilter: ["class", "data-theme-color-scheme"],
    });
  }

  async applyScheme(mode) {
    if (this.themeSelector?.setLocalThemeBasedOnColorScheme) {
      await this.themeSelector.setLocalThemeBasedOnColorScheme(mode);
      return;
    }

    if (this.themeSelector?.setColorScheme) {
      await this.themeSelector.setColorScheme(mode);
      return;
    }

    const root = document.documentElement;
    root.classList.toggle("dark", mode === "dark");
    root.dataset.themeColorScheme = mode;
  }

  postModeToFrame() {
    const frameWindow = this.iframeElement?.contentWindow;

    if (!frameWindow || this.frameFailed) {
      return;
    }

    frameWindow.postMessage(
      {
        type: "animated-scene-toggle:set-mode",
        mode: this.isLightMode ? "light" : "dark",
      },
      "*"
    );
  }

  markFrameFailed() {
    this.frameFailed = true;
    this.frameLoaded = false;
  }

  @action
  registerFrame(element) {
    this.iframeElement = element;
    this.frameLoaded = false;
    this.frameFailed = false;

    if (this.loadTimeout) {
      clearTimeout(this.loadTimeout);
    }

    this.loadTimeout = setTimeout(() => {
      if (!this.frameLoaded) {
        this.markFrameFailed();
      }
    }, 8000);

    element.addEventListener("load", () => {
      this.frameLoaded = true;
      this.frameFailed = false;
      if (this.loadTimeout) {
        clearTimeout(this.loadTimeout);
        this.loadTimeout = null;
      }
      this.postModeToFrame();
    });

    element.addEventListener("error", () => {
      this.markFrameFailed();
      if (this.loadTimeout) {
        clearTimeout(this.loadTimeout);
        this.loadTimeout = null;
      }
    });

    this.postModeToFrame();
  }

  @action
  async toggleTheme() {
    const nextMode = this.isLightMode ? "dark" : "light";
    await this.applyScheme(nextMode);
    this.isLightMode = nextMode === "light";
    this.postModeToFrame();
  }

  <template>
    {{#if this.shouldRender}}
      <li class="animated-scene-toggle-item">
        <DButton
          @action={{this.toggleTheme}}
          class={{this.buttonClass}}
          title={{this.title}}
          aria-label={{this.title}}
        >
          <span class="animated-scene-toggle__inner" aria-hidden="true">
            <iframe
              class="animated-scene-toggle__frame"
              src={{this.sceneUrl}}
              loading="eager"
              tabindex="-1"
              {{did-insert this.registerFrame}}
            ></iframe>
            {{#if this.frameFailed}}
              <span class="animated-scene-toggle__fallback" aria-hidden="true">
                <span class="animated-scene-toggle__fallback-dot"></span>
              </span>
            {{/if}}
          </span>
          {{#if this.debugText}}
            <span class="animated-scene-toggle__debug-text">{{this.debugText}}</span>
          {{/if}}
        </DButton>
      </li>
    {{/if}}
  </template>
}
