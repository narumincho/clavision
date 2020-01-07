import { Elm } from "./source/Main.elm";
const elmAppElement = document.createElement("div");

// bodyの子要素を削除
document.documentElement.replaceChild(
  document.body.cloneNode(false),
  document.body
);
document.body.appendChild(elmAppElement);

document.body.append(elmAppElement);

const accessTokenKey = "accessToken";

const flag = (): string | null => {
  const result = /accessToken=([^&]+)/.exec(location.hash);
  if (result !== null) {
    location.hash = "";
    const accessToken = result[1];
    localStorage.setItem(accessTokenKey, accessToken);
    return accessToken;
  }
  return localStorage.getItem(accessTokenKey);
};

const app = Elm.Main.init({
  flags: flag(),
  node: elmAppElement
});

app.ports.jumpPage.subscribe(url => {
  location.href = url;
});

app.ports.deleteAccessToken.subscribe(() => {
  localStorage.removeItem(accessTokenKey);
});

navigator.serviceWorker.register("./serviceWorker/serviceWorker.ts", {
  scope: "/"
});
