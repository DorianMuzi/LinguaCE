// Proxy serveur vers l'API Anthropic (Claude), durci (tâche #7).
// La clé API vit côté serveur (secret Supabase ANTHROPIC_API_KEY) — elle
// n'est JAMAIS exposée au client. Évite aussi les blocages CORS du navigateur.
//
// Durcissement :
//  - Auth : le JWT Supabase de l'appelant est validé (401 sinon). Le proxy
//    n'est plus ouvert : la clé anon publique ne suffit plus.
//  - Bornes serveur : max_tokens plafonné, nombre de messages et taille du
//    corps limités, sans faire confiance aux valeurs du client.
//  - Quota gratuit quotidien par utilisateur (serveur-autoritatif) : au-delà,
//    429. Barème via la variable d'env CHAT_DAILY_QUOTA (défaut 20).
//
// Secret :     supabase secrets set ANTHROPIC_API_KEY=sk-ant-...
// Quota (opt): supabase secrets set CHAT_DAILY_QUOTA=20
// Déploiement : supabase functions deploy chat

import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.4";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

// Bornes serveur — jamais dérivées des valeurs du client.
const MAX_TOKENS_CAP = 1024;
const MAX_MESSAGES = 24;
const MAX_BODY_BYTES = 262_144; // 256 KB (le system prompt grammatical est gros)
const DAILY_QUOTA = parseInt(Deno.env.get("CHAT_DAILY_QUOTA") ?? "20", 10);

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

function fail(
  code: string,
  message: string,
  status: number,
  extra: Record<string, unknown> = {},
): Response {
  return json({ error: { code, message, ...extra } }, status);
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  if (req.method !== "POST") {
    return fail("method_not_allowed", "Méthode non autorisée.", 405);
  }

  try {
    const apiKey = Deno.env.get("ANTHROPIC_API_KEY");
    if (!apiKey) {
      return fail(
        "server_misconfig",
        "ANTHROPIC_API_KEY non configurée côté serveur.",
        500,
      );
    }
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const anonKey = Deno.env.get("SUPABASE_ANON_KEY");
    if (!supabaseUrl || !anonKey) {
      return fail("server_misconfig", "Supabase non configuré côté fonction.", 500);
    }

    // ── 1) Auth : valider le JWT de l'appelant ──────────────────────────────
    const authHeader = req.headers.get("Authorization") ?? "";
    const jwt = authHeader.replace(/^Bearer\s+/i, "").trim();
    if (!jwt) {
      return fail("unauthorized", "Authentification requise.", 401);
    }
    const supabase = createClient(supabaseUrl, anonKey, {
      global: { headers: { Authorization: `Bearer ${jwt}` } },
      auth: { persistSession: false },
    });
    const { data: { user }, error: userErr } = await supabase.auth.getUser(jwt);
    if (userErr || !user) {
      return fail("unauthorized", "Session invalide ou expirée.", 401);
    }

    // ── 2) Corps + bornes (jamais confiance au client) ──────────────────────
    const raw = await req.text();
    if (raw.length > MAX_BODY_BYTES) {
      return fail("payload_too_large", "Requête trop volumineuse.", 413);
    }
    let parsed: Record<string, unknown>;
    try {
      parsed = JSON.parse(raw);
    } catch {
      return fail("bad_request", "JSON invalide.", 400);
    }
    const { model, max_tokens, system, messages, stream } = parsed as {
      model?: string;
      max_tokens?: number;
      system?: unknown;
      messages?: unknown;
      stream?: boolean;
    };
    if (!Array.isArray(messages) || messages.length === 0) {
      return fail("bad_request", "Aucun message.", 400);
    }
    if (messages.length > MAX_MESSAGES) {
      return fail("bad_request", "Trop de messages dans la requête.", 400);
    }
    const maxTokens = Math.min(
      Number.isFinite(Number(max_tokens)) ? Number(max_tokens) : MAX_TOKENS_CAP,
      MAX_TOKENS_CAP,
    );

    // ── 3) Quota quotidien (serveur-autoritatif, incrément atomique) ────────
    const { data: quota, error: quotaErr } = await supabase.rpc(
      "consume_chat_quota",
      { daily_limit: DAILY_QUOTA },
    );
    if (quotaErr) {
      return fail("server_error", "Vérification du quota impossible.", 500);
    }
    const row = Array.isArray(quota) ? quota[0] : quota;
    if (!row || row.allowed !== true) {
      return fail(
        "quota_exceeded",
        "Limite quotidienne de chat atteinte.",
        429,
        { used: row?.used, limit: row?.day_limit, reset_at: row?.reset_at },
      );
    }

    // ── 4) Appel Anthropic (max_tokens borné serveur) ───────────────────────
    const upstream = await fetch("https://api.anthropic.com/v1/messages", {
      method: "POST",
      headers: {
        "x-api-key": apiKey,
        "anthropic-version": "2023-06-01",
        "content-type": "application/json",
      },
      body: JSON.stringify({
        model: model ?? "claude-haiku-4-5-20251001",
        max_tokens: maxTokens,
        system,
        messages,
        ...(stream ? { stream: true } : {}),
      }),
    });

    // Streaming demandé et accepté : on pipe le flux SSE tel quel.
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

    // Sinon : corps JSON tel quel (le client lit `content` ou `error`).
    // Les erreurs AMONT Anthropic restent en 200 pour que le client les parse
    // via son chemin habituel ; seules NOS erreurs (auth/quota/bornes) portent
    // un vrai code HTTP.
    const data = await upstream.json();
    return json(data, 200);
  } catch (e) {
    return fail("server_error", String(e), 500);
  }
});
