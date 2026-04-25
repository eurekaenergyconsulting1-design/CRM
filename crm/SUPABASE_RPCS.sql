-- ═══════════════════════════════════════════════════════════════════════════
-- EUREKA CRM — RPCs PostgreSQL OBLIGATOIRES
-- Exécuter dans : Supabase Dashboard → SQL Editor → New query → Run
-- Projet : qjruqilnevfdbzsobrmu
--
-- PROBLÈME RÉSOLU : Ces 3 fonctions étaient ABSENTES du schéma initial.
-- Sans elles : authentification impossible, utilisateurs non sauvegardés.
-- ═══════════════════════════════════════════════════════════════════════════

-- ─────────────────────────────────────────────────────────────────────────
-- 1. authenticate_user — vérifie login + mot de passe, retourne l'utilisateur
-- ─────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.authenticate_user(p_login text, p_mdp text)
RETURNS SETOF public.crm_users
LANGUAGE sql
SECURITY DEFINER
STABLE
AS $$
  SELECT *
  FROM public.crm_users
  WHERE login = p_login
    AND mdp   = p_mdp
  LIMIT 1;
$$;

GRANT EXECUTE ON FUNCTION public.authenticate_user(text, text) TO anon;
GRANT EXECUTE ON FUNCTION public.authenticate_user(text, text) TO authenticated;

-- ─────────────────────────────────────────────────────────────────────────
-- 2. save_user — créer ou mettre à jour un utilisateur CRM
-- ─────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.save_user(
  p_id      text,
  p_login   text,
  p_mdp     text,
  p_nom     text,
  p_prenom  text,
  p_role    text,
  p_agent_id text,
  p_statut  text
)
RETURNS void
LANGUAGE sql
SECURITY DEFINER
AS $$
  INSERT INTO public.crm_users (id, login, mdp, nom, prenom, role, agent_id, statut)
  VALUES (p_id, p_login, p_mdp, p_nom, p_prenom, p_role, p_agent_id, p_statut)
  ON CONFLICT (id) DO UPDATE SET
    login    = EXCLUDED.login,
    mdp      = EXCLUDED.mdp,
    nom      = EXCLUDED.nom,
    prenom   = EXCLUDED.prenom,
    role     = EXCLUDED.role,
    agent_id = EXCLUDED.agent_id,
    statut   = EXCLUDED.statut;
$$;

GRANT EXECUTE ON FUNCTION public.save_user(text,text,text,text,text,text,text,text) TO anon;
GRANT EXECUTE ON FUNCTION public.save_user(text,text,text,text,text,text,text,text) TO authenticated;

-- ─────────────────────────────────────────────────────────────────────────
-- 3. list_users_safe — retourne tous les utilisateurs AVEC mdp
--    (nécessaire pour l'auth client-side du CRM interne)
-- ─────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.list_users_safe()
RETURNS SETOF public.crm_users
LANGUAGE sql
SECURITY DEFINER
STABLE
AS $$
  SELECT * FROM public.crm_users ORDER BY id;
$$;

GRANT EXECUTE ON FUNCTION public.list_users_safe() TO anon;
GRANT EXECUTE ON FUNCTION public.list_users_safe() TO authenticated;

-- ─────────────────────────────────────────────────────────────────────────
-- 4. Droits CRUD sur toutes les tables (anon key = clé publiable du CRM)
-- ─────────────────────────────────────────────────────────────────────────
GRANT ALL ON public.prospects  TO anon;
GRANT ALL ON public.agents     TO anon;
GRANT ALL ON public.crm_users  TO anon;
GRANT ALL ON public.objectifs  TO anon;
GRANT ALL ON public.journal    TO anon;
GRANT ALL ON public.config     TO anon;

-- Séquences (pour les IDs auto-générés)
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO anon;

-- ─────────────────────────────────────────────────────────────────────────
-- 5. Vérification que les policies RLS sont bien en place (USING true)
-- ─────────────────────────────────────────────────────────────────────────
DO $$
DECLARE
  tbl text;
  pol text;
BEGIN
  FOREACH tbl IN ARRAY ARRAY['prospects','agents','crm_users','journal','objectifs','config']
  LOOP
    -- Vérifier si une policy "all" existe, sinon la créer
    pol := 'eureka_' || tbl || '_all';
    IF NOT EXISTS (
      SELECT 1 FROM pg_policies WHERE tablename = tbl AND policyname = pol
    ) THEN
      EXECUTE format(
        'CREATE POLICY %I ON public.%I FOR ALL USING (true) WITH CHECK (true)',
        pol, tbl
      );
      RAISE NOTICE 'Policy créée sur %', tbl;
    ELSE
      RAISE NOTICE 'Policy déjà existante sur %', tbl;
    END IF;
  END LOOP;
END;
$$;

-- ─────────────────────────────────────────────────────────────────────────
-- 6. Vérification finale — doit retourner 6 tables et 3 fonctions
-- ─────────────────────────────────────────────────────────────────────────
SELECT 'TABLE' as type, table_name as name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN ('prospects','agents','crm_users','journal','objectifs','config')
UNION ALL
SELECT 'FUNCTION', routine_name
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name IN ('authenticate_user','save_user','list_users_safe')
ORDER BY type, name;
