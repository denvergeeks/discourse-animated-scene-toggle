import Component from "@glimmer/component";
import { service } from "@ember/service";
import { action } from "@ember/object";
import { tracked } from "@glimmer/tracking";
import { apiInitializer } from "discourse/lib/api";
import I18n from "discourse-i18n";

class MountainColorSchemeToggle extends Component {
  @service currentUser;
  @service themeSelector;

  @tracked isLightMode = false;

  constructor() {
    super(...arguments);
    this.syncFromDom();
    this.observeThemeState();
  }

  get shouldRender() {
    return settings.show_for_anons || !!this.currentUser;
  }

  get ariaLabel() {
    return this.isLightMode
      ? I18n.t("mountain_toggle.switch_to_dark")
      : I18n.t("mountain_toggle.switch_to_light");
  }

  get wrapperClasses() {
    let classes = ["mountain-toggle-scene-wrapper"];

    if (this.isLightMode) {
      classes.push("is-light-mode");
    }

    if (settings.enable_intro_animation) {
      classes.push("has-intro-animation");
    }

    return classes.join(" ");
  }

  get inlineStyle() {
    return `--mountain-toggle-width:${settings.toggle_width}px; --mountain-toggle-height:${settings.toggle_height}px;`;
  }

  syncFromDom() {
    const html = document.documentElement;
    const isDarkClass = html.classList.contains("dark");
    const colorScheme = html.dataset.themeColorScheme;

    this.isLightMode = !(isDarkClass || colorScheme === "dark");
  }

  observeThemeState() {
    if (this._observer) {
      return;
    }

    this._observer = new MutationObserver(() => this.syncFromDom());
    this._observer.observe(document.documentElement, {
      attributes: true,
      attributeFilter: ["class", "data-theme-color-scheme"],
    });
  }

  willDestroy() {
    super.willDestroy(...arguments);
    this._observer?.disconnect();
  }

  @action
  async toggleColorScheme() {
    this.syncFromDom();

    const nextMode = this.isLightMode ? "dark" : "light";

    if (this.themeSelector?.setLocalThemeBasedOnColorScheme) {
      await this.themeSelector.setLocalThemeBasedOnColorScheme(nextMode);
    } else if (this.themeSelector?.setColorScheme) {
      await this.themeSelector.setColorScheme(nextMode);
    } else {
      document.documentElement.classList.toggle("dark", nextMode === "dark");
      document.documentElement.dataset.themeColorScheme = nextMode;
    }

    this.isLightMode = nextMode === "light";
  }

  <template>
    {{#if this.shouldRender}}
      <li class="mountain-toggle-header-item">
        <button
          type="button"
          class="mountain-toggle-button"
          aria-label={{this.ariaLabel}}
          title={{this.ariaLabel}}
          style={{this.inlineStyle}}
          {{on "click" this.toggleColorScheme}}
        >
          <span class={{this.wrapperClasses}} aria-hidden="true">
            <span class="container">
              <span class="layer1">
                <svg
                  viewBox="0 0 263 525"
                  xmlns="http://www.w3.org/2000/svg"
                  preserveAspectRatio="xMidYMid slice"
                >
                  <defs>
                    <linearGradient id="mountain-night-sky" x1="0.5" y1="0" x2="0.5" y2="1">
                      <stop offset="0%" stop-color="#11233c" />
                      <stop offset="48%" stop-color="#214f78" />
                      <stop offset="70%" stop-color="#f29c78" />
                      <stop offset="100%" stop-color="#f9d67a" />
                    </linearGradient>
                  </defs>

                  <rect class="sky" width="263" height="525" fill="url(#mountain-night-sky)" />

                  <g class="sun">
                    <circle cx="207" cy="92" r="28" fill="#ffd46b" />
                  </g>

                  <g class="cloud1" fill="#fff" opacity="0.22">
                    <ellipse cx="60" cy="88" rx="34" ry="15" />
                    <ellipse cx="90" cy="88" rx="26" ry="12" />
                  </g>

                  <g class="cloud2" fill="#fff" opacity="0.18">
                    <ellipse cx="195" cy="150" rx="26" ry="12" />
                    <ellipse cx="220" cy="150" rx="19" ry="10" />
                  </g>

                  <g class="cloud3" fill="#fff" opacity="0.16">
                    <ellipse cx="80" cy="180" rx="22" ry="10" />
                    <ellipse cx="102" cy="180" rx="16" ry="8" />
                  </g>

                  <g class="cloud4" fill="#fff" opacity="0.14">
                    <ellipse cx="170" cy="70" rx="18" ry="8" />
                    <ellipse cx="190" cy="70" rx="12" ry="6" />
                  </g>

                  <g class="right" opacity="0.75">
                    <path
                      d="M205 210 C225 195, 245 180, 260 165 L263 330 L215 360 Z"
                      fill="#1b3d5a"
                    />
                  </g>

                  <g class="mountain7">
                    <path
                      d="M0 340 L32 300 L56 325 L90 260 L125 316 L165 240 L200 295 L230 250 L263 315 L263 525 L0 525 Z"
                      fill="#f27f63"
                    />
                  </g>

                  <g class="mountain6">
                    <path
                      d="M0 380 L40 350 L72 372 L110 330 L150 360 L185 320 L230 360 L263 345 L263 525 L0 525 Z"
                      fill="#cc5476"
                    />
                  </g>

                  <g class="mountain5">
                    <path
                      d="M0 420 L45 400 L90 415 L140 380 L190 404 L240 386 L263 398 L263 525 L0 525 Z"
                      fill="#9f5770"
                    />
                  </g>

                  <g class="mountain4">
                    <path
                      d="M0 450 L55 432 L105 446 L160 420 L220 450 L263 440 L263 525 L0 525 Z"
                      fill="#68566f"
                    />
                  </g>

                  <g class="m3">
                    <path
                      class="mountain3"
                      d="M0 470 L42 455 L85 475 L125 456 L170 480 L215 462 L263 478 L263 525 L0 525 Z"
                      fill="#504f6d"
                    />
                  </g>

                  <g class="mountain2">
                    <path
                      d="M0 492 L48 482 L108 494 L160 486 L220 500 L263 494 L263 525 L0 525 Z"
                      fill="#0e4764"
                    />
                  </g>

                  <g class="mountain1">
                    <path
                      d="M0 506 L54 500 L118 510 L182 504 L240 514 L263 512 L263 525 L0 525 Z"
                      fill="#083753"
                    />
                  </g>

                  <g class="tree" fill="#02284c" opacity="0.95">
                    <path d="M38 470 L52 430 L68 470 Z" />
                    <rect x="49" y="468" width="6" height="22" rx="2" />
                    <path d="M212 486 L228 438 L244 486 Z" />
                    <rect x="225" y="484" width="6" height="24" rx="2" />
                  </g>

                  <g class="moon" opacity="0.95">
                    <circle cx="85" cy="120" r="24" fill="#fff6cf" />
                    <circle cx="95" cy="112" r="24" fill="#214f78" />
                  </g>

                  <g class="rising-star" fill="#fff" opacity="0.92">
                    <circle cx="138" cy="76" r="2.6" />
                    <circle cx="156" cy="96" r="1.9" />
                    <circle cx="124" cy="102" r="1.8" />
                  </g>
                </svg>
              </span>

              <span class="layer2">
                <svg
                  viewBox="0 0 263 525"
                  xmlns="http://www.w3.org/2000/svg"
                  preserveAspectRatio="xMidYMid slice"
                >
                  <defs>
                    <linearGradient id="mountain-day-sky" x1="0.5" y1="0" x2="0.5" y2="1">
                      <stop offset="0%" stop-color="#67c7ff" />
                      <stop offset="55%" stop-color="#89d6ff" />
                      <stop offset="100%" stop-color="#e7f6ff" />
                    </linearGradient>
                  </defs>

                  <rect width="263" height="525" fill="url(#mountain-day-sky)" />

                  <g class="sun">
                    <circle cx="72" cy="95" r="30" fill="#ffd65f" />
                  </g>

                  <g class="cloud1" fill="#fff" opacity="0.94">
                    <ellipse cx="76" cy="92" rx="33" ry="15" />
                    <ellipse cx="104" cy="92" rx="24" ry="12" />
                  </g>

                  <g class="cloud2" fill="#fff" opacity="0.9">
                    <ellipse cx="190" cy="112" rx="29" ry="13" />
                    <ellipse cx="216" cy="112" rx="20" ry="10" />
                  </g>

                  <g class="cloud3" fill="#fff" opacity="0.86">
                    <ellipse cx="74" cy="154" rx="24" ry="11" />
                    <ellipse cx="96" cy="154" rx="17" ry="8" />
                  </g>

                  <g class="cloud4" fill="#fff" opacity="0.82">
                    <ellipse cx="185" cy="78" rx="18" ry="8" />
                    <ellipse cx="202" cy="78" rx="12" ry="6" />
                  </g>

                  <g class="mountain7">
                    <path
                      d="M0 340 L32 300 L56 325 L90 260 L125 316 L165 240 L200 295 L230 250 L263 315 L263 525 L0 525 Z"
                      fill="#8bb174"
                    />
                  </g>

                  <g class="mountain6">
                    <path
                      d="M0 380 L40 350 L72 372 L110 330 L150 360 L185 320 L230 360 L263 345 L263 525 L0 525 Z"
                      fill="#6f9f64"
                    />
                  </g>

                  <g class="mountain5">
                    <path
                      d="M0 420 L45 400 L90 415 L140 380 L190 404 L240 386 L263 398 L263 525 L0 525 Z"
                      fill="#628b60"
                    />
                  </g>

                  <g class="mountain4">
                    <path
                      d="M0 450 L55 432 L105 446 L160 420 L220 450 L263 440 L263 525 L0 525 Z"
                      fill="#587768"
                    />
                  </g>

                  <g class="m3">
                    <path
                      class="mountain3"
                      d="M0 470 L42 455 L85 475 L125 456 L170 480 L215 462 L263 478 L263 525 L0 525 Z"
                      fill="#50676b"
                    />
                  </g>

                  <g class="mountain2">
                    <path
                      d="M0 492 L48 482 L108 494 L160 486 L220 500 L263 494 L263 525 L0 525 Z"
                      fill="#356172"
                    />
                  </g>

                  <g class="mountain1">
                    <path
                      d="M0 506 L54 500 L118 510 L182 504 L240 514 L263 512 L263 525 L0 525 Z"
                      fill="#244c60"
                    />
                  </g>

                  <g class="tree" fill="#183a2d" opacity="0.95">
                    <path d="M38 470 L52 430 L68 470 Z" />
                    <rect x="49" y="468" width="6" height="22" rx="2" />
                    <path d="M212 486 L228 438 L244 486 Z" />
                    <rect x="225" y="484" width="6" height="24" rx="2" />
                  </g>

                  <g class="moon" opacity="0">
                    <circle cx="85" cy="120" r="24" fill="#fff6cf" />
                    <circle cx="95" cy="112" r="24" fill="#89d6ff" />
                  </g>

                  <g class="rising-star" fill="#fff" opacity="0">
                    <circle cx="138" cy="76" r="2.6" />
                    <circle cx="156" cy="96" r="1.9" />
                    <circle cx="124" cy="102" r="1.8" />
                  </g>
                </svg>
              </span>
            </span>
          </span>
        </button>
      </li>
    {{/if}}
  </template>
}

export default apiInitializer((api) => {
  api.headerIcons.add("mountain-color-scheme-toggle", MountainColorSchemeToggle, {
    before: settings.insert_before_icon || "search",
  });
});
