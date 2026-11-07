"use client";

import { useEffect, useMemo, useState } from "react";
import { createClient } from "@supabase/supabase-js";

const baseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const publishableKey = process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY;
const slots = { morning: "Matin", midday: "Midi", evening: "Soir" };
const statuses = {
  draft: "Brouillon", biblical_review: "Relecture biblique",
  linguistic_review: "Relecture linguistique", approval_review: "Approbation",
  approved: "Approuvé", scheduled: "Planifié", published: "Publié", withdrawn: "Retiré",
};
const actions = [
  ["submit", "Envoyer en relecture biblique"],
  ["biblical_approve", "Valider la relecture biblique"],
  ["linguistic_approve", "Valider la relecture linguistique"],
  ["approve", "Approuver"],
  ["schedule", "Planifier"],
  ["publish", "Publier"],
  ["request_changes", "Demander des corrections"],
  ["withdraw", "Retirer"],
];
const initialForm = {
  content_date: "2099-01-01", slot: "morning", language_code: "fr",
  translation_code: "demo", translation_name: "Démonstration",
  reference: "DÉMO 1:1", verse_text: "Texte fictif de démonstration, sans citation biblique.",
  reflection: "Méditation fictive pour vérifier le circuit éditorial.",
  action: "Action fictive pour la démonstration.", prayer: "",
  attribution: "Contenu fictif — aucun verset biblique.", source_provider: "demo",
  source_bible_id: "", source_passage_id: "",
};
const fields = [
  ["content_date", "Date", "date"], ["slot", "Créneau", "slot"],
  ["language_code", "Langue", "text"], ["translation_code", "Code traduction", "text"],
  ["translation_name", "Nom traduction", "text"], ["reference", "Référence", "text"],
  ["verse_text", "Texte", "textarea"], ["reflection", "Méditation", "textarea"],
  ["action", "Action", "textarea"], ["prayer", "Prière", "textarea"],
  ["attribution", "Attribution", "textarea"], ["source_provider", "Source", "text"],
  ["source_bible_id", "Bible ID", "text"], ["source_passage_id", "Passage ID", "text"],
];

export default function EditorialPage() {
  const supabase = useMemo(() => baseUrl && publishableKey
    ? createClient(baseUrl, publishableKey) : null, []);
  const [user, setUser] = useState(null);
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [items, setItems] = useState([]);
  const [selected, setSelected] = useState(null);
  const [events, setEvents] = useState([]);
  const [form, setForm] = useState(initialForm);
  const [creating, setCreating] = useState(false);
  const [reason, setReason] = useState("");
  const [filter, setFilter] = useState("");
  const [hasMore, setHasMore] = useState(false);
  const [busy, setBusy] = useState(false);
  const [message, setMessage] = useState("");

  async function request(path = "", options = {}) {
    const { data: { session } } = await supabase.auth.getSession();
    if (!session) throw new Error("Session expirée. Reconnectez-vous.");
    const response = await fetch(`${baseUrl}/functions/v1/editorial-contents${path}`, {
      ...options,
      headers: {
        apikey: publishableKey, Authorization: `Bearer ${session.access_token}`,
        ...(options.body ? { "Content-Type": "application/json" } : {}),
      },
      cache: "no-store",
    });
    const body = await response.json();
    if (!response.ok) throw new Error(body.error?.message || "Opération impossible.");
    return body.data;
  }

  async function loadItems(status = filter, append = false) {
    const offset = append ? items.length : 0;
    const query = new URLSearchParams({ offset: String(offset) });
    if (status) query.set("status", status);
    const data = await request(`?${query}`);
    setItems(append ? [...items, ...data] : data);
    setHasMore(data.length === 100);
  }

  async function loadDetail(id) {
    const data = await request(`?id=${encodeURIComponent(id)}`);
    setSelected(data.content);
    setEvents(data.events);
    setForm(Object.fromEntries(Object.keys(initialForm).map((key) => [key, data.content[key] ?? ""])));
    setCreating(false);
  }

  useEffect(() => {
    if (!supabase) return;
    supabase.auth.getUser().then(({ data }) => setUser(data.user ?? null));
    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
      setUser(session?.user ?? null);
    });
    return () => subscription.unsubscribe();
  }, [supabase]);

  useEffect(() => {
    if (!user || !supabase) return;
    loadItems().catch((error) => setMessage(error.message));
  }, [user, supabase]);

  async function signIn(event) {
    event.preventDefault();
    setBusy(true); setMessage("");
    const { error } = await supabase.auth.signInWithPassword({ email, password });
    setPassword(""); setBusy(false);
    if (error) setMessage("Connexion impossible. Vérifiez le compte et le mot de passe.");
  }

  async function mutate(action, payload = {}) {
    setBusy(true); setMessage("");
    try {
      const content = await request("", {
        method: "POST",
        body: JSON.stringify({ action, content_id: action === "create" ? null : selected?.id, payload }),
      });
      await loadItems();
      await loadDetail(content.id);
      setReason("");
      setMessage("Modification enregistrée.");
    } catch (error) {
      setMessage(error.message);
    } finally { setBusy(false); }
  }

  const roles = user?.app_metadata?.roles;
  const roleLabel = Array.isArray(roles) ? roles.join(", ") : roles || "aucun rôle";
  const status = selected?.editorial_status;
  const allowedActions = {
    draft: ["submit"], biblical_review: ["biblical_approve", "request_changes"],
    linguistic_review: ["linguistic_approve", "request_changes"],
    approval_review: ["approve", "request_changes"], approved: ["schedule"],
    scheduled: ["publish", "withdraw"], published: ["withdraw"], withdrawn: [],
  }[status] || [];

  if (!supabase) return <main className="setup"><h1>Configuration requise</h1><p>Renseignez <code>admin/.env.local</code> avec l’URL Supabase et la clé publiable.</p></main>;
  if (!user) return <main className="login"><div className="login-card">
    <div className="brand-mark">✦</div><p className="eyebrow">Gaius Care</p>
    <h1>ThanksGiving Quote</h1><p>Administration éditoriale</p>
    <form onSubmit={signIn}>
      <label>Adresse e-mail<input type="email" value={email} onChange={(e) => setEmail(e.target.value)} required /></label>
      <label>Mot de passe<input type="password" value={password} onChange={(e) => setPassword(e.target.value)} required /></label>
      <button disabled={busy} type="submit">Se connecter</button>
    </form>{message && <p className="notice error">{message}</p>}
  </div></main>;

  return <div className="app-shell">
    <header className="topbar"><div><span className="logo">✦</span><div><strong>ThanksGiving Quote</strong><small>Rendre Grâce à DIEU chaque jour</small></div></div>
      <div className="account"><span>{user.email}<small>{roleLabel}</small></span><button className="ghost" onClick={() => supabase.auth.signOut()}>Déconnexion</button></div></header>
    <main className="workspace">
      <aside className="queue"><div className="queue-head"><div><p className="eyebrow">CIRCUIT ÉDITORIAL</p><h1>Contenus</h1></div><button onClick={() => { setCreating(true); setSelected(null); setEvents([]); setForm(initialForm); }}>+ Nouveau</button></div>
        <label className="filter">Statut<select value={filter} onChange={(e) => { setFilter(e.target.value); loadItems(e.target.value).catch((error) => setMessage(error.message)); }}><option value="">Tous</option>{Object.entries(statuses).map(([key, label]) => <option key={key} value={key}>{label}</option>)}</select></label>
        <div className="item-list">{items.map((item) => <button key={item.id} className={`item ${selected?.id === item.id ? "active" : ""}`} onClick={() => loadDetail(item.id).catch((error) => setMessage(error.message))}>
          <span className="item-top"><strong>{slots[item.slot]} · {item.content_date}</strong><span className={`pill ${item.editorial_status}`}>{statuses[item.editorial_status]}</span></span>
          <span>{item.reference} · {item.translation_name}</span><small>Version {item.version} · {item.language_code.toUpperCase()}</small>
        </button>)}{!items.length && <p className="empty">Aucun contenu pour ce filtre.</p>}{hasMore && <button className="ghost" onClick={() => loadItems(filter, true).catch((error) => setMessage(error.message))}>Charger plus</button>}</div>
      </aside>
      <section className="editor">{message && <div className="notice" role="status">{message}<button onClick={() => setMessage("")}>×</button></div>}
        {creating || selected ? <><div className="editor-head"><div><p className="eyebrow">{creating ? "NOUVEAU BROUILLON" : `${statuses[status]} · Version ${selected.version}`}</p><h2>{creating ? "Créer un contenu" : `${slots[selected.slot]} · ${selected.content_date}`}</h2></div>{selected && <span className="id">ID {selected.id}</span>}</div>
          <div className="panel"><div className="form-grid">{fields.map(([key, label, type]) => <label key={key} className={type === "textarea" ? "wide" : ""}>{label}{type === "slot" ? <select value={form[key]} disabled={!creating && status !== "draft"} onChange={(e) => setForm({ ...form, [key]: e.target.value })}>{Object.entries(slots).map(([value, name]) => <option key={value} value={value}>{name}</option>)}</select> : type === "textarea" ? <textarea rows={key === "verse_text" ? 4 : 2} value={form[key]} disabled={!creating && status !== "draft"} onChange={(e) => setForm({ ...form, [key]: e.target.value })} /> : <input type={type} value={form[key]} disabled={!creating && status !== "draft"} onChange={(e) => setForm({ ...form, [key]: e.target.value })} />}</label>)}</div>
            {(creating || status === "draft") && <div className="form-footer"><button disabled={busy} onClick={() => mutate(creating ? "create" : "edit", form)}>{creating ? "Créer le brouillon" : "Enregistrer le brouillon"}</button></div>}
          </div>
          {selected && <><div className="panel"><h3>Décision éditoriale</h3><p className="muted">Chaque étape est contrôlée par un rôle distinct. L’auteur ne peut pas relire ni approuver son propre contenu.</p>
            {allowedActions.some((a) => a === "request_changes" || a === "withdraw") && <label>Motif de correction ou de retrait<textarea rows={2} value={reason} onChange={(e) => setReason(e.target.value)} placeholder="Motif obligatoire pour les corrections et les retraits" /></label>}
            <div className="action-row">{actions.filter(([key]) => allowedActions.includes(key)).map(([key, label]) => <button key={key} className={key === "withdraw" || key === "request_changes" ? "secondary" : ""} disabled={busy || ((key === "withdraw" || key === "request_changes") && !reason.trim())} onClick={() => mutate(key, { reason })}>{label}</button>)}</div>
            {status === "scheduled" && <p className="warning">Publication de démonstration désactivée par défaut. Aucun texte JND ne peut être publié.</p>}
          </div><div className="panel"><h3>Historique</h3><ol className="timeline">{events.map((event) => <li key={event.id}><strong>{event.action.replaceAll("_", " ")}</strong><span>{event.from_status ? `${statuses[event.from_status]} → ` : ""}{statuses[event.to_status]}</span><small>{new Date(event.occurred_at).toLocaleString("fr-FR")} · {event.actor_id}</small>{event.reason && <p>{event.reason}</p>}</li>)}</ol></div></>}
        </> : <div className="welcome"><div className="welcome-icon">✦</div><h2>Trois rendez-vous de grâce.</h2><p>Sélectionnez un contenu pour suivre sa relecture ou créez un brouillon de démonstration.</p><p className="warning">Le texte JND reste bloqué à la publication jusqu’à validation de ses droits.</p></div>}
      </section>
    </main>
  </div>;
}
