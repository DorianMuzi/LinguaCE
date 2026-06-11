// Proxy serveur vers l'API Anthropic (Claude).
// La clé API vit côté serveur (secret Supabase ANTHROPIC_API_KEY) — elle
// n'est JAMAIS exposée au client. Évite aussi les blocages CORS du navigateur.
//
// Secret :   supabase secrets set ANTHROPIC_API_KEY=sk-ant-...
// Déploiement : supabase functions deploy chat

import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  try {
    const apiKey = Deno.env.get("ANTHROPIC_API_KEY");
    if (!apiKey) {
      return json(
        { error: { message: "ANTHROPIC_API_KEY non configurée côté serveur." } },
        500,
      );
    }

    const { model, max_tokens, system, messages, stream } = await req.json();

    const upstream = await fetch("https://api.anthropic.com/v1/messages", {
      method: "POST",
      headers: {
        "x-api-key": apiKey,
        "anthropic-version": "2023-06-01",
        "content-type": "application/json",
      },
      body: JSON.stringify({
        model: model ?? "claude-haiku-4-5-20251001",
        max_tokens: max_tokens ?? 1024,
        system,
        messages,
        ...(stream ? { stream: true } : {}),
      }),
    });

    // Streaming demandé et accepté : on pipe le flux SSE Anthropic tel
    // quel vers le client (la réponse s'affiche au fil des tokens).
    if (stream && upstream.ok && upstream.body) {
      return new Response(upstream.body, {
        status: 200,
        headers: {
          ...corsHeaders,
          "Content-Type": "text/event-stream",
          "Cache-Control": "no-cache",
        },
      });
    }

    // Sinon (pas de stream demandé, ou erreur amont) : corps JSON tel
    // quel, toujours en 200 côté fonction — le client lit `content` ou
    // `error` dans le JSON.
    const data = await upstream.json();
    return json(data, 200);
  } catch (e) {
    return json({ error: { message: String(e) } }, 500);
  }
});
