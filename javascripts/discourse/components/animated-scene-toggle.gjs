import Component from "@glimmer/component";
import { service } from "@ember/service";
import { action } from "@ember/object";
import { tracked } from "@glimmer/tracking";
import DButton from "discourse/components/d-button";
import I18n from "discourse-i18n";

export default class AnimatedSceneToggle extends Component {
  @service currentUser;
  @service themeSelector;

  @tracked isDark = false;

  constructor() {
    super(...arguments);
    this.syncState();

    this.observer = new MutationObserver(() => this.syncState());

    this.observer.observe(document.documentElement, {
      attributes: true,
      attributeFilter: ["class", "data-theme-color-scheme"],
    });
  }

  willDestroy() {
    super.willDestroy(...arguments);
    this.observer?.disconnect();
  }

  get shouldRender() {
    return settings.show_for_anons || !!this.currentUser;
  }

  get buttonClass() {
    const classes = ["btn", "no-text", "animated-scene-toggle-header-button"];
    classes.push(this.isDark ? "dark-mode" : "light-mode");

    if (settings.compact_mode) {
      classes.push("is-compact");
    }

    return classes.join(" ");
  }

  get title() {
    return this.isDark
      ? I18n.t(themePrefix("animated_scene_toggle.switch_to_light"))
      : I18n.t(themePrefix("animated_scene_toggle.switch_to_dark"));
  }

  get labelText() {
    return I18n.t(themePrefix("animated_scene_toggle.label"));
  }

  get showLabel() {
    return settings.show_label;
  }

  syncState() {
    const root = document.documentElement;

    this.isDark =
      root.classList.contains("dark") ||
      root.dataset.themeColorScheme === "dark";
  }

  async setMode(mode) {
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

  @action
  async toggleTheme() {
    await this.setMode(this.isDark ? "light" : "dark");
    this.syncState();
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
          <:default>
            <span class="animated-scene-toggle__inner" aria-hidden="true">
              <span
                class="animated-scene-toggle__scene-root {{if this.isDark 'dark-mode' 'light-mode'}}"
              >
                <svg
                  class="animated-scene-toggle__svg"
                  viewBox="0 0 72 36"
                  xmlns="http://www.w3.org/2000/svg"
                  aria-hidden="true"
                  focusable="false"
                >
                  <use href="#animated-scene-toggle-light"></use>
                </svg>

                <svg
                  class="animated-scene-toggle__svg animated-scene-toggle__svg--dark"
                  viewBox="0 0 72 36"
                  xmlns="http://www.w3.org/2000/svg"
                  aria-hidden="true"
                  focusable="false"
                >
                  <use href="#animated-scene-toggle-dark"></use>
                </svg>

                <span class="animated-scene-toggle__thumb"></span>
              </span>
            </span>

            {{#if this.showLabel}}
              <span class="animated-scene-toggle__label">
                {{this.labelText}}
              </span>
            {{/if}}
          </:default>
        </DButton>
      </li>
    {{/if}}
  </template>
}
