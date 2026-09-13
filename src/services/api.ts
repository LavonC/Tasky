const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:3007';

export function getAuthHeaders(): Record<string, string> {
  const token = sessionStorage.getItem('tasky_token');

  return {
    'Content-Type': 'application/json',
    ...(token ? { Authorization: `Bearer ${token}` } : {}),
  };
}

export { API_URL };