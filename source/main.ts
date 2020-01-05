import { Elm } from "./source/Main.elm";
const elmAppElement = document.createElement("div");

// bodyの子要素を削除
document.documentElement.replaceChild(
  document.body.cloneNode(false),
  document.body
);
document.body.appendChild(elmAppElement);

document.body.append(elmAppElement);

const flag = () => {
  const result = /accessToken=([^&]+)/.exec(location.hash);
  if (result === null) {
    return null;
  }
  location.hash = "";
  return result[1];
};

const app = Elm.Main.init({
  flags: flag(),
  node: elmAppElement
});

app.ports.jumpPage.subscribe(url => {
  location.href = url;
});

navigator.serviceWorker.register("./serviceWorker/serviceWorker.ts", {
  scope: "/"
});
