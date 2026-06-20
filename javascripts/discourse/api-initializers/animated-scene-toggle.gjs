import { apiInitializer } from "discourse/lib/api";
import AnimatedSceneToggle from "../components/animated-scene-toggle";

export default apiInitializer("1.34.0", (api) => {
  api.headerIcons.add("animated-scene-toggle", <AnimatedSceneToggle />, {
    before: settings.toggle_before_icon || "search",
  });
});
