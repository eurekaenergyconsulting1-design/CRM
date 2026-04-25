-- ═══════════════════════════════════════════════════════════════════════════
-- EUREK ACRM — SCHÉMA SUPABASE COMPLET
-- Projet : qjruqilnevfdbzsobrmu
-- Exécuter dans : Supabase Dashboard → SQL Editor → New query
-- ═══════════════════════════════════════════════════════════════════════════

-- ── Extensions ───────────────────────────────────────────────────────────
create extension if not exists "uuid-ossp";

-- ═══════════════════════════════════════════════════════════════════════════
-- TABLE : agents
-- ═══════════════════════════════════════════════════════════════════════════
create table if not exists public.agents (
  id          text primary key,           -- ex: 'a1', 'a2', 'a'+Date.now()
  nom         text not null,
  date_debut  date,
  actif       boolean default true,
  created_at  timestamptz default now(),
  updated_at  timestamptz default now()
);
comment on table public.agents is 'Agents téléprospecteurs Eureka Energy Consulting';

-- ═══════════════════════════════════════════════════════════════════════════
-- TABLE : crm_users
-- ═══════════════════════════════════════════════════════════════════════════
create table if not exists public.crm_users (
  id          text primary key,           -- ex: 'u0', 'u1', 'u'+Date.now()
  login       text unique not null,
  mdp         text,                       -- hash ou texte (usage interne)
  nom         text,
  prenom      text,
  role        text default 'agent',       -- 'superadmin'|'admin'|'agent'
  statut      text default 'agent_confirme', -- 'stagiaire'|'agent_confirme'
  agent_id    text references public.agents(id) on delete set null,
  created_at  timestamptz default now()
);
comment on table public.crm_users is 'Utilisateurs du CRM (login interne, sans Supabase Auth)';

-- ═══════════════════════════════════════════════════════════════════════════
-- TABLE : prospects (dossiers clients)
-- ═══════════════════════════════════════════════════════════════════════════
create table if not exists public.prospects (
  -- Identifiant
  id                      bigint primary key,   -- Date.now() côté client

  -- Société
  societe                 text,
  siret                   text,
  naf                     text,
  groupe                  text,
  nb_sites                int default 1,
  nb_pdl                  int default 0,
  nb_pce                  int default 0,

  -- Adresse
  adresse_rue             text,
  cp                      text,
  ville                   text,

  -- Contacts
  decideur                text,
  interlocuteur           text,
  signataire              text,
  poste                   text,
  tel_p                   text,
  tel_p2                  text,
  tel_f                   text,
  tel_f2                  text,
  email                   text,
  email2                  text,
  creneau                 text default 'Indifférent',

  -- Énergie Électricité
  segment_elec            text default 'C5',
  pdl                     text,
  puissance               text,
  fournisseur_actuel_elec text,
  fournisseur_propose_elec text,
  car_elec                text,
  duree_elec              text,
  marge_elec              text,
  date_ech_elec           text,

  -- Énergie Gaz
  pce                     text,
  fournisseur_actuel_gaz  text,
  fournisseur_propose_gaz text,
  car_gaz                 text,
  duree_gaz               text,
  marge_gaz               text,
  date_ech_gaz            text,

  -- Commercial
  type                    text default 'Acquisition',
  statut                  text default 'Prospect',
  agent_id                text references public.agents(id) on delete set null,
  date_pro                text,
  date_facture            text,
  date_sig                text,
  date_rgpd               text,
  date_rappel_client      text,
  raison_perte            text,
  concurrent_retenu       text,
  date_rappel_perte       text,

  -- Notes
  notes                   text,
  notes_internes          text,

  -- Qualification
  score_elipro            text,
  score_credit_safe       text,
  autorisation_enedis     text default 'Non',
  valeur_car              text,
  valeur_duree            text,
  valeur_marge            text,

  -- JSON
  docs                    jsonb default '{}',
  appel_history           jsonb default '[]',

  -- Timestamps
  created_at              timestamptz default now(),
  updated_at              timestamptz default now()
);
comment on table public.prospects is 'Dossiers prospects/clients — données énergie B2B';

-- ═══════════════════════════════════════════════════════════════════════════
-- TABLE : journal
-- ═══════════════════════════════════════════════════════════════════════════
create table if not exists public.journal (
  id          bigserial primary key,
  ts          text not null,              -- format JJ/MM/AAAA HH:MM:SS
  user_name   text,
  action      text,
  detail      text,
  ip          text,
  created_at  timestamptz default now()
);
comment on table public.journal is 'Journal d activité et audit trail';

-- ═══════════════════════════════════════════════════════════════════════════
-- TABLE : objectifs
-- ═══════════════════════════════════════════════════════════════════════════
create table if not exists public.objectifs (
  agent_id    text primary key,          -- agentId, ou agentId_m1/m2/m3 pour targets par période
  valeur      int default 0,             -- objectif CA mensuel en €
  updated_at  timestamptz default now()
);
comment on table public.objectifs is 'Objectifs CA mensuels par agent (clés: agentId, agentId_m1, agentId_m2, agentId_m3)';

-- ═══════════════════════════════════════════════════════════════════════════
-- TABLE : rappels  (rendez-vous / préclos — synchronisés multi-agents)
-- ═══════════════════════════════════════════════════════════════════════════
create table if not exists public.rappels (
  id          text primary key,
  date        text,
  heure       text default '08:00',
  type        text default 'préclos',   -- 'préclos'|'présentation'|'closing'
  numero      text,
  mail        text,
  note        text,
  entreprise  text,
  created_by  text,
  created_at  timestamptz default now(),
  updated_at  timestamptz default now()
);
comment on table public.rappels is 'Rendez-vous / rappels préclos — synchronisés multi-agents';

-- ═══════════════════════════════════════════════════════════════════════════
-- TABLE : config  (clé/valeur JSON — regles, commissions payées, etc.)
-- ═══════════════════════════════════════════════════════════════════════════
create table if not exists public.config (
  key         text primary key,
  value       jsonb,
  updated_at  timestamptz default now()
);
comment on table public.config is 'Configuration globale du CRM (JSON key/value)';

-- ═══════════════════════════════════════════════════════════════════════════
-- INDEX — performances requêtes fréquentes
-- ═══════════════════════════════════════════════════════════════════════════
create index if not exists idx_prospects_statut     on public.prospects(statut);
create index if not exists idx_prospects_agent_id   on public.prospects(agent_id);
create index if not exists idx_prospects_date_sig   on public.prospects(date_sig);
create index if not exists idx_prospects_siret      on public.prospects(siret);
create index if not exists idx_prospects_societe    on public.prospects(societe);
create index if not exists idx_journal_action       on public.journal(action);
create index if not exists idx_journal_user_name    on public.journal(user_name);
create index if not exists idx_journal_created_at   on public.journal(created_at desc);

-- ═══════════════════════════════════════════════════════════════════════════
-- TRIGGER — updated_at automatique
-- ═══════════════════════════════════════════════════════════════════════════
create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_prospects_updated_at on public.prospects;
create trigger trg_prospects_updated_at
  before update on public.prospects
  for each row execute function public.set_updated_at();

drop trigger if exists trg_agents_updated_at on public.agents;
create trigger trg_agents_updated_at
  before update on public.agents
  for each row execute function public.set_updated_at();

-- ═══════════════════════════════════════════════════════════════════════════
-- RLS — Row Level Security
-- ═══════════════════════════════════════════════════════════════════════════
alter table public.prospects        enable row level security;
alter table public.agents           enable row level security;
alter table public.journal          enable row level security;
alter table public.crm_users        enable row level security;
alter table public.objectifs        enable row level security;
alter table public.config           enable row level security;
alter table public.rappels          enable row level security;

-- Policies : accès total via clé publiable (CRM interne, pas de compte Auth)
-- NOTE : Pour sécuriser davantage en production, restreindre à service_role key
create policy "eureka_prospects_all"  on public.prospects  for all using (true) with check (true);
create policy "eureka_agents_all"     on public.agents     for all using (true) with check (true);
create policy "eureka_journal_all"    on public.journal    for all using (true) with check (true);
create policy "eureka_users_all"      on public.crm_users  for all using (true) with check (true);
create policy "eureka_objectifs_all"  on public.objectifs  for all using (true) with check (true);
create policy "eureka_config_all"     on public.config     for all using (true) with check (true);
create policy "eureka_rappels_all"    on public.rappels    for all using (true) with check (true);

-- ═══════════════════════════════════════════════════════════════════════════
-- DONNÉES INITIALES — agents, utilisateurs, objectifs
-- ═══════════════════════════════════════════════════════════════════════════
insert into public.agents (id, nom, date_debut, actif) values
  ('a1', 'Marc-Antoine Koné', '2024-11-01', true),
  ('a2', 'Sophie Dossou',     '2023-06-01', true),
  ('a3', 'Romain Adjovi',     '2024-01-01', true)
on conflict (id) do nothing;

insert into public.crm_users (id, login, mdp, nom, prenom, role, agent_id) values
  ('u0', 'super',  'super2024',  'Admin',       'Super',         'superadmin', null),
  ('u1', 'admin',  'eureka2024', 'Admin',       'Eureka',        'admin',      null),
  ('u2', 'marc',   'agent123',   'Koné',        'Marc-Antoine',  'agent',      'a1'),
  ('u3', 'sophie', 'agent123',   'Dossou',      'Sophie',        'agent',      'a2')
on conflict (id) do nothing;

insert into public.objectifs (agent_id, valeur) values
  ('a1', 8000),
  ('a2', 12000),
  ('a3', 6000)
on conflict (agent_id) do nothing;

-- ═══════════════════════════════════════════════════════════════════════════
-- MIGRATION : ajout colonne statut sur base existante (à exécuter 1 fois)
-- ═══════════════════════════════════════════════════════════════════════════
alter table public.crm_users
  add column if not exists statut text default 'agent_confirme';

-- ═══════════════════════════════════════════════════════════════════════════
-- VÉRIFICATION FINALE
-- ═══════════════════════════════════════════════════════════════════════════
select
  table_name,
  (select count(*) from information_schema.columns c
   where c.table_name = t.table_name and c.table_schema = 'public') as nb_colonnes
from information_schema.tables t
where table_schema = 'public'
  and table_name in ('prospects','agents','crm_users','journal','objectifs','config')
order by table_name;

-- ═══════════════════════════════════════════════════════════════════════════
-- FIN DU SCHÉMA
-- Après exécution : aller dans Settings → API → copier la "Publishable Key"
-- La coller dans EurekaCRM → Paramètres → ☁️ Supabase → Clé publiable
-- ═══════════════════════════════════════════════════════════════════════════
