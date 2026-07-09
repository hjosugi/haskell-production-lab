export default {
  async fetch(request) {
    const url = new URL(request.url);
    const src = url.searchParams.get("src");
    if (!src) return new Response("missing src", { status: 400 });

    // Cloudflare image resizing policy boundary.
    return fetch(src, {
      cf: {
        image: {
          width: Number(url.searchParams.get("w") || 800),
          quality: Number(url.searchParams.get("q") || 85),
          fit: "scale-down"
        }
      }
    });
  }
};
