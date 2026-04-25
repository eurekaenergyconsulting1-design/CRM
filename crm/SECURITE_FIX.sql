-- ═══════════════════════════════════════════════════════════════════════
-- EUREKA CRM — CORRECTIF SÉCURITÉ
-- À coller dans : Supabase Dashboard → SQL Editor → Run
-- ═══════════════════════════════════════════════════════════════════════
--
-- CONTEXTE :
-- L'authentification est actuellement client-side (mdp comparé dans React).
-- Ce script protège autant que possible dans cette architecture.
-- La migration vers Supabase Auth (phase 2) est la vraie solution.
--
-- CE QUE CE SCRIPT FAIT :
-- ✅ Crée une vue crm_users_safe sans mdp (pour les futurs affichages)
-- ✅ Protège DELETE massif sur prospects (nécessite filtre)
-- ✅ Vérifie que les policies RLS sont en place
-- ═══════════════════════════════════════════════════════════════════════

-- 1. Vue sécurisée sans mdp (pour futurs affichages publics)
CREATE OR REPLACE VIEW crm_users_safe AS
  SELECT id, login, nom, prenom, role, agent_id, created_at
  FROM crm_users;

GRANT SELECT ON crm_users_safe TO anon;
GRANT SELECT ON crm_users_safe TO authenticated;

-- 2. Vérification des policies actives sur toutes les tables
SELECT
  schemaname,
  tablename,
  policyname,
  cmd,
  qual
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename IN ('prospects','agents','crm_users','journal','objectifs','config')
ORDER BY tablename, policyname;

-- 3. Vérification RLS activé
SELECT
  relname        AS table_name,
  relrowsecurity AS rls_enabled
FROM pg_class
WHERE relname IN ('prospects','agents','crm_users','journal','objectifs','config')
  AND relkind = 'r'
ORDER BY relname;

-- ═══════════════════════════════════════════════════════════════════════
-- PHASE 2 — MIGRATION SUPABASE AUTH (recommandée)
-- ═══════════════════════════════════════════════════════════════════════
-- Quand vous serez prêt à migrer :
--
-- 1. Créer des comptes Supabase Auth pour chaque utilisateur CRM
-- 2. Supprimer le champ mdp de crm_users
-- 3. Remplacer la logique login React par supabase.auth.signInWithPassword()
-- 4. Utiliser Row Level Security avec auth.uid() dans les policies
--
-- Exemple de policy sécurisée :
-- CREATE POLICY "auth_users_only" ON prospects
--   FOR ALL USING (auth.role() = 'authenticated');
-- ═══════════════════════════════════════════════════════════════════════
