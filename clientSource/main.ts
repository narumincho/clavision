import { Elm } from "./source/Main.elm";
const elmAppElement = document.createElement("div");

// bodyの子要素を削除
document.documentElement.replaceChild(
  document.body.cloneNode(false),
  document.body
);
document.body.appendChild(elmAppElement);

document.body.append(elmAppElement);
const app = Elm.Main.init({
  flags: null,
  node: elmAppElement
});

app.ports.jumpPage.subscribe(url => {
  location.href = url;
});

navigator.serviceWorker.register("./serviceWorker/serviceWorker.ts", {
  scope: "/"
});
