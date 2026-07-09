export default {
  async fetch(request) {
    const url = new URL(request.url);
    const html = `<!doctype html>
<html><head><meta charset="utf-8"><title>Humblr</title></head>
<body><h1>Humblr</h1><p>SSR route: ${url.pathname}</p></body></html>`;
    return new Response(html, { headers: { "content-type": "text/html;charset=utf-8" } });
  }
};
