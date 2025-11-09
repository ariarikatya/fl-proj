'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "25995ccc11d6e300a3107dd92b7fc7c4",
"assets/AssetManifest.bin.json": "d128e9d41b80bc19a59cedbdb91f32d9",
"assets/AssetManifest.json": "60239a523d51ac34d1b66f35cf95fb79",
"assets/assets/images/master_photo.png": "be8bef592fe30fe4f3e60cad100675ea",
"assets/assets/images/pink_splash.svg": "7b5b57352149bbffd9ade6e5cdb378f3",
"assets/assets/images/polka_logo.svg": "6a119e406821e0e56730b3eafafd7846",
"assets/assets/images/welcome_illustration.png": "3d79dcf94e7e80ed0947be40464d8407",
"assets/FontManifest.json": "a47bfd76c2f03bf17cdc634fff3742ed",
"assets/fonts/MaterialIcons-Regular.otf": "96b1ab3ca5f1067c4fff6d8a93e78218",
"assets/NOTICES": "185745e842e3876abc8cc5267be1481f",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/packages/shared/assets/icons/eye.png": "0c42cd01b485251f9d856bffae39ad45",
"assets/packages/shared/assets/icons/hair.png": "0786cf391a2a87fd9b180a546b2d2060",
"assets/packages/shared/assets/icons/lipstick.png": "48b38b98881658dd15a174eba42a060d",
"assets/packages/shared/assets/icons/lollipop.png": "e0fac224367cfa27318fb4258031dd7b",
"assets/packages/shared/assets/icons/nails.png": "ee39a85ecbb777617223e455e2848b60",
"assets/packages/shared/assets/icons/razor.png": "1e17cae8e3e36a7dd392d99d3149fb5e",
"assets/packages/shared/assets/icons/scissors.png": "845d8ff2f60043a0c1becb308e5dd5bd",
"assets/packages/shared/assets/icons/star.png": "c181f84bc401706ce230cee3eb80fe99",
"assets/packages/shared/assets/images/master_avatar_default.png": "3671a493ac035b266fb37676235a2c64",
"assets/packages/shared/assets/images/profile_image.png": "0d899b12bd6e6f95b3301a176e327532",
"assets/packages/shared/lib/fonts/Manrope-Bold.ttf": "8e8fe178c0f147b91ed2a2b3097ad8a4",
"assets/packages/shared/lib/fonts/Manrope-ExtraBold.ttf": "f8f555c6d9efacc1b0af255e815a97da",
"assets/packages/shared/lib/fonts/Manrope-ExtraLight.ttf": "ec4a6e976cec7c2fa377e9f24e292338",
"assets/packages/shared/lib/fonts/Manrope-Light.ttf": "7c8bdfd65f2d0d081069e438f953359f",
"assets/packages/shared/lib/fonts/Manrope-Medium.ttf": "de7b3026c153d63d5732582887fecbf4",
"assets/packages/shared/lib/fonts/Manrope-Regular.ttf": "8ca1a84037fdb644723129315c390ad9",
"assets/packages/shared/lib/fonts/Manrope-SemiBold.ttf": "80cb1b1a8ba262608706cb7f2b017835",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "140ccb7d34d0a55065fbd422b843add6",
"canvaskit/canvaskit.js.symbols": "58832fbed59e00d2190aa295c4d70360",
"canvaskit/canvaskit.wasm": "07b9f5853202304d3b0749d9306573cc",
"canvaskit/chromium/canvaskit.js": "5e27aae346eee469027c80af0751d53d",
"canvaskit/chromium/canvaskit.js.symbols": "193deaca1a1424049326d4a91ad1d88d",
"canvaskit/chromium/canvaskit.wasm": "24c77e750a7fa6d474198905249ff506",
"canvaskit/skwasm.js": "1ef3ea3a0fec4569e5d531da25f34095",
"canvaskit/skwasm.js.symbols": "0088242d10d7e7d6d2649d1fe1bda7c1",
"canvaskit/skwasm.wasm": "264db41426307cfc7fa44b95a7772109",
"canvaskit/skwasm_heavy.js": "413f5b2b2d9345f37de148e2544f584f",
"canvaskit/skwasm_heavy.js.symbols": "3c01ec03b5de6d62c34e17014d1decd3",
"canvaskit/skwasm_heavy.wasm": "8034ad26ba2485dab2fd49bdd786837b",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "888483df48293866f9f41d3d9274a779",
"flutter_bootstrap.js": "4a9dce1593d12344a407d384ecf0acdf",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "a63a1fd1c66af945c8b323eda60e4c76",
"/": "a63a1fd1c66af945c8b323eda60e4c76",
"main.dart.js": "d4c9bcff631d99a8d7f94e6f7dfc4e28",
"manifest.json": "9b04d261340f347aa43693b172637454",
"version.json": "62d4f3ccbc68a7c2ce111721371fc07e"};
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
