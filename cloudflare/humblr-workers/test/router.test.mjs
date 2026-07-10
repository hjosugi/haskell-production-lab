import { createExecutionContext } from "cloudflare:test";
import { describe, expect, it, vi } from "vitest";
import router from "../workers/router.mjs";

describe("Humblr Router service binding", () => {
  it("forwards article requests to the Database Worker binding", async () => {
    const databaseFetch = vi.fn(async () => Response.json({ articles: [] }));
    const fallbackFetch = vi.fn(async () => new Response("not used"));
    const env = {
      APP_ENV: "development",
      DATABASE: { fetch: databaseFetch },
      STORAGE: { fetch: fallbackFetch },
      IMAGES: { fetch: fallbackFetch },
      SSR: { fetch: fallbackFetch },
    };
    const request = new Request("https://humblr.example/api/articles?limit=10");

    const response = await router.fetch(request, env, createExecutionContext());

    expect(response.status).toBe(200);
    expect(databaseFetch).toHaveBeenCalledOnce();
    expect(databaseFetch).toHaveBeenCalledWith(request);
    expect(fallbackFetch).not.toHaveBeenCalled();
  });
});
