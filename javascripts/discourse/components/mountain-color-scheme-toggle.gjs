import Component from "@glimmer/component";
import { inject as service } from "@ember/service";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import I18n from "discourse-i18n";

export default class MountainColorSchemeToggle extends Component {
  @service currentUser;
  @service themeSelector;

  @tracked isDark = false;

  constructor() {
    super(...arguments);
    this.syncState();
    this.observeHtml();
  }

  get shouldRender() {
    if (settings.show_for_anons) {
      return true;
    }
    return !!this.currentUser;
  }

  get ariaLabel() {
    return this.isDark
      ? I18n.t("mountain_toggle.switch_to_light")
      : I18n.t("mountain_toggle.switch_to_dark");
  }

  get scaleStyle() {
    // Scale the original 263x525 container into the header
    const s = settings.mountain_toggle_scale || 0.22;
    return `transform: scale(${s}); transform-origin: top right;`;
  }

  syncState() {
    const html = document.documentElement;
    const scheme =
      html.dataset.themeColorScheme ||
      html.getAttribute("data-theme-color-scheme") ||
      "";
    this.isDark = scheme === "dark";
  }

  observeHtml() {
    if (this._observer) {
      return;
    }
    const html = document.documentElement;
    this._observer = new MutationObserver(() => this.syncState());
    this._observer.observe(html, {
      attributes: true,
      attributeFilter: ["data-theme-color-scheme"]
    });
  }

  willDestroy() {
    super.willDestroy(...arguments);
    this._observer?.disconnect();
  }

  @action
  async toggleColorScheme() {
    // Flip Discourse color scheme via the same mechanism core uses
    const target = this.isDark ? "light" : "dark";

    // Prefer the core color-scheme helper if exposed
    if (this.themeSelector?.toggleColorSchemePreference) {
      await this.themeSelector.toggleColorSchemePreference(target);
    } else if (this.themeSelector?.setColorSchemeFromLocalMode) {
      // Legacy helper from discourse-color-scheme-toggle
      await this.themeSelector.setColorSchemeFromLocalMode(target);
    }

    // Local visual state will be updated by the MutationObserver,
    // but we also flip immediately for responsiveness
    this.isDark = !this.isDark;
  }

  <template>
    {{#if this.shouldRender}}
      <li class="mountain-toggle-header-item">
        <button
          type="button"
          class="mountain-toggle-button"
          aria-label={{this.ariaLabel}}
          title={{this.ariaLabel}}
          {{on "click" this.toggleColorScheme}}
        >
          <span
            class={{concat
              "mountain-toggle-scene-wrapper "
              (if this.isDark "is-light-mode" "")
            }}
            style={{this.scaleStyle}}
          >
            {{! Device frame }}
            <svg
              class="device"
              width="278"
              height="555"
              viewBox="0 0 278 555"
              xmlns="http://www.w3.org/2000/svg"
              aria-hidden="true"
            >
              <rect
                x="0.311859"
                y="0.0585327"
                width="277.05"
                height="554.736"
                rx="25.4758"
                fill="#0E0E0E"
              />
            </svg>

            <div class="container">
              <div class="toggle"></div>

              {{! NIGHT SCENE – layer1 }}
              <div class="layer1">
                {{{this.nightSvg}}}
              </div>

              {{! DAY SCENE – layer2 }}
              <div class="layer2">
                {{{this.daySvg}}}
              </div>
            </div>
          </span>
        </button>
      </li>
    {{/if}}
  </template>

  // NOTE:
  // To keep this file manageable, the huge SVG contents are split
  // into getters that return safe HTML strings. Replace the markers
  // below with the raw SVG content from your txt file, but with the
  // *inner content only* (everything inside <svg>…</svg>).

  get nightSvg() {
    return `
<svg width="263" height="525" viewBox="0 0 263 525" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- BEGIN: paste the full night SVG inner content from svg-for-dark-and-light-mountain-scene.txt layer1 here -->
  <!-- Keep all class names: sky, mountain1..7, m3, tree, right, cloud1..4, light, etc. -->
  <!-- END night SVG -->
</svg>
    `.trim();
  }

  get daySvg() {
    return `
<svg width="263" height="525" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- BEGIN: paste the full day SVG inner content from svg-for-dark-and-light-mountain-scene.txt layer2 here -->
  <!-- Keep all class names: moon, rising-star, star, cloud1..4, etc. -->
  <!-- END day SVG -->
</svg>
    `.trim();
  }
}
