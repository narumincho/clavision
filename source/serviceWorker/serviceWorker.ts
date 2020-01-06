((self: ServiceWorkerGlobalScope): void => {
  self.addEventListener("install", e => {
    console.log("service worker installed!!");
    e.waitUntil(self.skipWaiting());
  });

  self.addEventListener("activate", e => {
    e.waitUntil(self.clients.claim());
  });

  self.addEventListener("fetch", e => {
    e.waitUntil(
      (async () => {
        const response = await caches.match(e.request);
        if (response !== undefined) {
          e.respondWith(response);
          return;
        }
        (await caches.open("cacheName")).add(e.request);
      })()
    );
  });
})((self as unknown) as ServiceWorkerGlobalScope);
