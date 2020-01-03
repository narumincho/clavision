((self: ServiceWorkerGlobalScope): void => {
  self.addEventListener("install", e => {
    console.log("service worker installed!!");
    e.waitUntil(self.skipWaiting());
  });
  self.addEventListener("activate", e => {
    e.waitUntil(self.clients.claim());
  });
})((self as unknown) as ServiceWorkerGlobalScope);
