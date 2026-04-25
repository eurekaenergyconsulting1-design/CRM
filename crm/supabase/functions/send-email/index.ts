// ══════════════════════════════════════════════════════════════════════════════
// EUREKA CRM — Edge Function Supabase : Envoi d'emails via Resend
// ══════════════════════════════════════════════════════════════════════════════
//
// DÉPLOIEMENT (1 seule fois, depuis le terminal) :
//   1. npm install -g supabase           (installer CLI Supabase si absent)
//   2. supabase login                    (se connecter)
//   3. supabase link --project-ref qjruqilnevfdbzsobrmu
//   4. supabase secrets set RESEND_API_KEY=re_VOTRE_CLE_RESEND
//   5. supabase functions deploy send-email --no-verify-jwt
//
// URL de la fonction après déploiement :
//   https://qjruqilnevfdbzsobrmu.supabase.co/functions/v1/send-email
//
// USAGE (appelé par le CRM via window.email.send()) :
//   POST  body JSON : { to, subject, html, from? }
//   Auth  header   : Authorization: Bearer <anon_key>
// ══════════════════════════════════════════════════════════════════════════════

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

// En-têtes CORS — autorise les appels depuis Vercel (et tout autre domaine)
const CORS = {
  "Access-Control-Allow-Origin":  "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

// ── Types ─────────────────────────────────────────────────────────────────────
interface EmailPayload {
  to:       string | string[];
  subject:  string;
  html:     string;
  from?:    string;
}

// ── Validation email basique ──────────────────────────────────────────────────
function isValidEmail(email: string): boolean {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email.trim());
}

// ── Handler principal ─────────────────────────────────────────────────────────
serve(async (req: Request) => {

  // ── Pre-flight CORS ──────────────────────────────────────────────────────
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: CORS, status: 200 });
  }

  // ── Méthode ──────────────────────────────────────────────────────────────
  if (req.method !== "POST") {
    return json(
      { error: "Méthode non autorisée — utilisez POST" },
      405
    );
  }

  // ── Clé Resend (variable d'env Supabase) ─────────────────────────────────
  const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY");
  if (!RESEND_API_KEY) {
    console.error("[send-email] RESEND_API_KEY absent des secrets Supabase");
    return json(
      { error: "Configuration manquante : RESEND_API_KEY. Exécutez : supabase secrets set RESEND_API_KEY=re_xxx" },
      500
    );
  }

  // ── Parse du corps ────────────────────────────────────────────────────────
  let payload: EmailPayload;
  try {
    payload = await req.json() as EmailPayload;
  } catch (_) {
    return json({ error: "Corps de requête invalide — JSON attendu" }, 400);
  }

  const { to, subject, html, from } = payload;

  // ── Validation champs obligatoires ───────────────────────────────────────
  if (!to || !subject || !html) {
    return json(
      { error: "Champs obligatoires manquants : to, subject, html" },
      400
    );
  }
  if (typeof subject !== "string" || subject.trim().length === 0) {
    return json({ error: "Le champ 'subject' ne peut pas être vide" }, 400);
  }
  if (typeof html !== "string" || html.trim().length === 0) {
    return json({ error: "Le champ 'html' ne peut pas être vide" }, 400);
  }

  // ── Normalisation + validation des destinataires ─────────────────────────
  const toArray: string[] = (Array.isArray(to) ? to : [to])
    .map((e) => String(e).trim())
    .filter((e) => e.length > 0);

  if (toArray.length === 0) {
    return json({ error: "Aucun destinataire fourni" }, 400);
  }

  const invalidEmails = toArray.filter((e) => !isValidEmail(e));
  if (invalidEmails.length > 0) {
    return json(
      { error: `Adresses email invalides : ${invalidEmails.join(", ")}` },
      400
    );
  }

  // ── Expéditeur par défaut ─────────────────────────────────────────────────
  const fromAddress = (typeof from === "string" && from.trim().length > 0)
    ? from.trim()
    : "Eureka Energy Consulting <noreply@eureka-energy.fr>";

  // ── Appel API Resend ──────────────────────────────────────────────────────
  let resendResponse: Response;
  try {
    resendResponse = await fetch("https://api.resend.com/emails", {
      method:  "POST",
      headers: {
        "Authorization": `Bearer ${RESEND_API_KEY}`,
        "Content-Type":  "application/json",
      },
      body: JSON.stringify({
        from:    fromAddress,
        to:      toArray,
        subject: subject.trim(),
        html:    html,
      }),
    });
  } catch (networkErr) {
    const msg = networkErr instanceof Error ? networkErr.message : String(networkErr);
    console.error("[send-email] Erreur réseau vers Resend:", msg);
    return json(
      { error: `Erreur réseau lors de l'appel Resend : ${msg}` },
      502
    );
  }

  // ── Lecture réponse Resend ────────────────────────────────────────────────
  let resendData: Record<string, unknown> = {};
  try {
    resendData = await resendResponse.json();
  } catch (_) {
    // La réponse n'est pas du JSON — on continue
  }

  if (!resendResponse.ok) {
    const errMsg =
      (typeof resendData.message === "string" && resendData.message) ||
      (typeof resendData.name    === "string" && resendData.name)    ||
      `Erreur Resend HTTP ${resendResponse.status}`;

    console.error("[send-email] Erreur Resend:", errMsg, resendData);
    return json(
      { error: errMsg, detail: resendData },
      resendResponse.status
    );
  }

  // ── Succès ────────────────────────────────────────────────────────────────
  const emailId = typeof resendData.id === "string" ? resendData.id : null;
  console.log(
    `[send-email] ✅ Succès — id: ${emailId} — destinataire(s): ${toArray.join(", ")}`
  );

  return json({ success: true, id: emailId }, 200);
});

// ── Helper : réponse JSON avec CORS ──────────────────────────────────────────
function json(
  body: Record<string, unknown>,
  status = 200
): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...CORS, "Content-Type": "application/json" },
  });
}
