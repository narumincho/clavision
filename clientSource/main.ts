import { Elm } from "./source/Main.elm";
const app = Elm.Main.init({
  flags: null
});

app.ports.jumpPage.subscribe(url => {
  location.href = url;
});
