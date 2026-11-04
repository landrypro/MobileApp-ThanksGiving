const state = {
  favorites: { morning: false, midday: false, evening: false },
  favoriteCount: 12,
  translation: "Louis Segond 1910",
  language: "Français · FR",
  reminders: { morning: true, midday: true, evening: false },
  slot: "midday",
};

const dailyContent = {
  morning: {
    name: "Matin",
    label: "MATIN · VERSET 1 SUR 3",
    available: "Disponible depuis 05 h 00",
    reference: "PSAUME 92:2",
    verse: "Il est beau de louer l’Éternel, Et de célébrer ton nom, ô Très Haut !",
    reflection: "Commencez cette journée en nommant une grâce déjà présente dans votre vie.",
    action: "Commencer avec gratitude",
  },
  midday: {
    name: "Midi",
    label: "MIDI · VERSET 2 SUR 3",
    available: "Disponible depuis 12 h 00",
    reference: "PSAUME 100:4",
    verse: "Entrez dans ses portes avec des louanges, dans ses parvis avec des cantiques ! Célébrez-le, bénissez son nom !",
    reflection: "Faites une pause pour reconnaître la bonté de DIEU au cœur de votre journée.",
    action: "Remercier DIEU maintenant",
  },
  evening: {
    name: "Soir",
    label: "SOIR · VERSET 3 SUR 3",
    available: "Disponible depuis 18 h 00",
    reference: "1 THESSALONICIENS 5:18",
    verse: "Rendez grâces en toutes choses, car c’est à votre égard la volonté de Dieu en Jésus-Christ.",
    reflection: "Relisez votre journée avec DIEU et déposez-lui ce qui a été vécu, avec reconnaissance.",
    action: "Terminer avec gratitude",
  },
};

const fixedFavorites = [
  ["1 THESSALONICIENS 5:18", "Rendez grâces en toutes choses, car c’est à votre égard la volonté de Dieu.", "Louis Segond 1910 · Soir · 27 oct."],
  ["PSAUME 107:1", "Louez l’Éternel, car il est bon, car sa miséricorde dure à toujours !", "Louis Segond 1910 · Matin · 24 oct."],
];

const $ = (selector) => document.querySelector(selector);
const $$ = (selector) => [...document.querySelectorAll(selector)];

function showScreen(id) {
  $$(".screen").forEach((screen) => screen.classList.toggle("screen--active", screen.id === id));
  $$(".nav-item").forEach((button) => button.classList.toggle("is-active", button.dataset.go === id));
  $(".bottom-nav").hidden = id === "welcome" || id === "translations";
}

function toast(message) {
  const node = $("#toast");
  node.textContent = message;
  node.classList.add("is-visible");
  window.clearTimeout(toast.timer);
  toast.timer = window.setTimeout(() => node.classList.remove("is-visible"), 2600);
}

function renderCalendar() {
  const days = $("#calendar-days");
  days.innerHTML = "<span></span><span></span><span></span>";
  for (let day = 1; day <= 31; day += 1) {
    const item = document.createElement("span");
    item.textContent = day;
    if (day <= 28) item.classList.add("is-done");
    if (day === 28) item.classList.add("is-current");
    days.append(item);
  }
}

function displayedVerse(content) {
  if (state.translation === "Louis Segond 1910") return content.verse;
  return `Le texte exact de ${state.translation} sera affiché après validation de ses droits d’usage.`;
}

function renderToday() {
  const content = dailyContent[state.slot];
  $("#slot-label").textContent = content.label;
  $("#daily-quote").textContent = displayedVerse(content);
  $("#daily-reference").textContent = content.reference;
  $("#slot-time").textContent = content.available;
  $("#translation-label").textContent = `${state.translation} · aperçu`;
  $("#reflection-copy").textContent = content.reflection;
  $("#gratitude-button").innerHTML = `${content.action} <span aria-hidden="true">→</span>`;
  const next = { morning: "Prochain : midi · 12 h", midday: "Prochain : soir · 18 h", evening: "Prochain : demain · matin · 05 h" };
  $("#next-reading").textContent = next[state.slot];
  $$(".slot-tab").forEach((button) => {
    const selected = button.dataset.slot === state.slot;
    button.classList.toggle("is-active", selected);
    button.setAttribute("aria-selected", String(selected));
  });
  updateFavorite();
}

function favoriteCard(reference, verse, meta) {
  return `<article class="favorite-card"><small>${reference}</small><blockquote>${verse}</blockquote><div class="favorite-card__footer"><span>${meta}</span><button data-share="${reference}">Partager →</button></div></article>`;
}

function renderFavorites() {
  const cards = [...fixedFavorites];
  Object.entries(state.favorites).reverse().forEach(([slot, favorite]) => {
    if (!favorite) return;
    const content = dailyContent[slot];
    cards.unshift([content.reference, displayedVerse(content), `${state.translation} · ${content.name} · aujourd’hui`]);
  });
  $("#favorites-list").innerHTML = cards.map((item) => favoriteCard(...item)).join("");
  $("#favorite-count").textContent = `${state.favoriteCount} VERSETS GARDÉS`;
}

function updateFavorite() {
  const button = $("#favorite-button");
  const isFavorite = state.favorites[state.slot];
  button.classList.toggle("is-favorite", isFavorite);
  button.setAttribute("aria-pressed", String(isFavorite));
  button.setAttribute("aria-label", isFavorite ? "Retirer ce verset des favoris" : "Ajouter ce verset aux favoris");
  button.querySelector("span").textContent = isFavorite ? "★" : "☆";
  button.querySelector("small").textContent = isFavorite ? "Gardé" : "À garder";
}

function setTranslation(name) {
  state.translation = name;
  $$(".translation-option").forEach((option) => {
    const selected = option.dataset.translation === name;
    option.classList.toggle("is-selected", selected);
    option.setAttribute("aria-checked", String(selected));
    option.querySelector("em").textContent = selected ? "ACTUELLE" : "Selon droits";
  });
  $("#settings-translation").textContent = name;
  renderToday();
  renderFavorites();
}

function openShare(reference) {
  const content = dailyContent[state.slot];
  const verseReference = reference || content.reference;
  $("#modal-copy").textContent = `${verseReference} · ${state.translation}`;
  $("#modal").hidden = false;
}

function closeModal() { $("#modal").hidden = true; }

function toggleReminder(slot) {
  state.reminders[slot] = !state.reminders[slot];
  const button = $(`[data-reminder="${slot}"]`);
  const active = state.reminders[slot];
  const label = dailyContent[slot].name.toLowerCase();
  button.classList.toggle("is-on", active);
  button.setAttribute("aria-pressed", String(active));
  button.setAttribute("aria-label", `${active ? "Désactiver" : "Activer"} le rappel du ${label}`);
  toast(active ? `Rappel du ${label} activé` : `Rappel du ${label} désactivé`);
}

function initializeInteractions() {
  $$('[data-go]').forEach((button) => button.addEventListener("click", () => {
    if (button.dataset.slot) state.slot = button.dataset.slot;
    showScreen(button.dataset.go);
    renderToday();
  }));
  $$(".slot-tab").forEach((button) => button.addEventListener("click", () => {
    state.slot = button.dataset.slot;
    renderToday();
    toast(`${dailyContent[state.slot].name} sélectionné`);
  }));
  $$(".translation-option").forEach((button) => button.addEventListener("click", () => {
    setTranslation(button.dataset.translation);
    toast(`${button.dataset.translation} sélectionnée`);
    window.setTimeout(() => showScreen("today"), 350);
  }));
  $("#favorite-button").addEventListener("click", () => {
    state.favorites[state.slot] = !state.favorites[state.slot];
    state.favoriteCount += state.favorites[state.slot] ? 1 : -1;
    updateFavorite();
    renderFavorites();
    toast(state.favorites[state.slot] ? "Verset ajouté aux favoris" : "Verset retiré des favoris");
  });
  $("#share-button").addEventListener("click", () => openShare());
  $("#gratitude-button").addEventListener("click", () => toast("Votre espace de gratitude sera disponible dans la version complète."));
  $$(".modal-close").forEach((button) => button.addEventListener("click", closeModal));
  $("#modal").addEventListener("click", (event) => { if (event.target.id === "modal") closeModal(); });
  $$("[data-reminder]").forEach((button) => button.addEventListener("click", () => toggleReminder(button.dataset.reminder)));
  $$(".chip").forEach((button) => button.addEventListener("click", () => {
    state.language = button.dataset.language;
    $$(".chip").forEach((chip) => {
      const selected = chip === button;
      chip.classList.toggle("is-selected", selected);
      chip.setAttribute("aria-checked", String(selected));
    });
    $("#current-language").textContent = state.language;
    $$(".language-button").forEach((item) => { item.textContent = state.language.split("·")[1].trim(); });
    toast(`${state.language} sélectionné`);
  }));
  $("#change-language").addEventListener("click", () => toast("Choisissez l’une des 8 langues ci-dessous."));
  $("#favorites-list").addEventListener("click", (event) => {
    const share = event.target.closest("[data-share]");
    if (share) openShare(share.dataset.share);
  });
}

renderCalendar();
renderToday();
renderFavorites();
initializeInteractions();
