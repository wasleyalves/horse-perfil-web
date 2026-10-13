// ===== Origem da API Horse conforme o ambiente =====
// Em desenvolvimento (aberto localmente), fala direto com o Horse.
// Em produção (Vercel), usa o proxy same-origin /api definido no vercel.json.
window.API_ORIGIN =
  (location.hostname === 'localhost' || location.hostname === '127.0.0.1')
    ? 'http://localhost:9000' // dev local
    : '/api';                 // produção (proxy Vercel -> túnel)
