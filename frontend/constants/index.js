// constants/index.js
function getApiBase() {
  if (typeof window !== 'undefined' && window.location && window.location.hostname.endsWith('.app.github.dev')) {
    // Codespace: replace the port segment with 3001
    const host = window.location.hostname.replace(/-\d+\./, '-3001.');
    return `https://${host}/api`;
  }
  // Fallback for local dev
  return 'http://localhost:3001/api';
}

export const API_BASE = getApiBase();