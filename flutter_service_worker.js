'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "85fc17692fc1aa980e1ff2ac9a1d1c65",
"assets/assets/images/booking_hotel_logo.png": "b59d4518425675460bf8ae115860caae",
"assets/assets/images/hotel-dashboard.jpg": "e04a631cf77341747b6d9d96f4ecb7e0",
"assets/assets/images/profile_emty.png": "649ad6816e3f2fbf025a343e75afef59",
"assets/assets/images/logo_2.png": "97b4823d4efcec00baf1781d3d325be4",
"assets/assets/images/kong.jpg": "79fb940c57dbe38fc4936d59654db461",
"assets/assets/icons/info.svg": "fbc5992f12351a9dd8c8c44304ef84b7",
"assets/assets/icons/gift.svg": "a2344510bbb754dfc8c75986b629bd08",
"assets/assets/icons/bin.svg": "41e54d12bcaf4f3459bafca78713de09",
"assets/assets/icons/pin-area.svg": "417ec24ae8ff86b873d2990c3c1edf7b",
"assets/assets/icons/setting.svg": "4b05cfa3802cc36138a33d453b5c7f25",
"assets/assets/icons/favorite-border.svg": "fe4a7aa6853246329ec0ba46b8763acc",
"assets/assets/icons/call.svg": "78625de1925bad7c9362b81b4662907e",
"assets/assets/icons/favorited.svg": "e089edd00c159f49e100aee42ab6bed1",
"assets/assets/icons/search.svg": "9a7ccc346d7f472cf58c1f7a2e4a938e",
"assets/assets/icons/hotel.svg": "b3b0c446eccf1e833d7aaf8c444485be",
"assets/assets/icons/lock.svg": "5e25936aa3aa3c1ce3202e673f57f3d3",
"assets/assets/icons/filter.svg": "a4ebc1c18fdb4f49e7fd41488d110426",
"assets/assets/icons/shield.svg": "ada2fcc365fa51ca31f89d56f91d20f4",
"assets/assets/icons/clock.svg": "263de5cc99e9ef80664ce7eb3faff928",
"assets/assets/icons/pool.svg": "955d1c28c4447cb8382a283a4c58cc6e",
"assets/assets/icons/home.svg": "336bf63b2714dd2a9476a5e671691b0b",
"assets/assets/icons/snack.svg": "0dc82c4252263c85681f25821df73291",
"assets/assets/icons/edit.svg": "791f8754919393c28dd141eea85bc959",
"assets/assets/icons/bed.svg": "44848657b1e65703816d91459b1c732a",
"assets/assets/icons/booking.svg": "ad8ab382a09841366b06d443e911107a",
"assets/assets/icons/explore.svg": "222dea12b63e013aa1347cd003c0a8db",
"assets/assets/icons/food.svg": "001dbbab76f1df02dd8397c97bfb2606",
"assets/assets/icons/bell.svg": "5e99779d6e9d3973e4e5aa9c45285a29",
"assets/assets/icons/camera.svg": "30e423cb6583f668a3a36772b8f43d9d",
"assets/assets/icons/pin.svg": "eab691301dd9923b0fb4fe12ae01c36a",
"assets/assets/icons/exit.svg": "20c58cb6d90a349df7c45c522ca93d8a",
"assets/assets/icons/wifi.svg": "39c2fff83b1a30e746b00cbd0d7dac6b",
"assets/assets/icons/car.svg": "65daa5c5ccef0e6dbb0444f4caf3cd58",
"assets/assets/icons/favorite.svg": "6f8a5ed57b63c79bb6f9d20b5e67983f",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/AssetManifest.json": "40d8cb977d3e1ed88b50d614d6447dce",
"assets/fonts/MaterialIcons-Regular.otf": "03bd07694bcb79f64dc2d01edddaa161",
"assets/AssetManifest.bin.json": "d121a0bdb57351a4f76fd67f2b5bbdd5",
"assets/NOTICES": "b8b68ecc16fe2da12a20ed5c7cffce6f",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"version.json": "994029a9378629a262c96e5a8be9609c",
"manifest.json": "1d63b994f422480fcfe8a21d164e7324",
"flutter_bootstrap.js": "e913ea125aaf99f6748cd6e492625bf5",
"canvaskit/skwasm.wasm": "39dd80367a4e71582d234948adc521c0",
"canvaskit/canvaskit.wasm": "7a3f4ae7d65fc1de6a6e7ddd3224bc93",
"canvaskit/skwasm.js.symbols": "e72c79950c8a8483d826a7f0560573a1",
"canvaskit/chromium/canvaskit.wasm": "f504de372e31c8031018a9ec0a9ef5f0",
"canvaskit/chromium/canvaskit.js": "8191e843020c832c9cf8852a4b909d4c",
"canvaskit/chromium/canvaskit.js.symbols": "b61b5f4673c9698029fa0a746a9ad581",
"canvaskit/skwasm.js": "ea559890a088fe28b4ddf70e17e60052",
"canvaskit/canvaskit.js": "728b2d477d9b8c14593d4f9b82b484f3",
"canvaskit/canvaskit.js.symbols": "bdcd3835edf8586b6d6edfce8749fb77",
"index.html": "4702e86deda407cd177081f48ca80555",
"/": "4702e86deda407cd177081f48ca80555",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "83d881c1dbb6d6bcd6b42e274605b69c",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"main.dart.js": "bed5689c975e590ed66712c8ca740463"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
