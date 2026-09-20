import { API_URL } from './api';

async function request<T>(path: string, options: RequestInit = {}): Promise<T> {
  const token = sessionStorage.getItem('tasky_token');
  const response = await fetch(`${API_URL}${path}`, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
      ...options.headers,
    },
  });
  if (!response.ok) throw new Error((await response.json()).message || 'Request failed');
  return response.json() as Promise<T>;
}

export function createManagerInvite(email: string) {
  return request<{ code: string }>('/api/invites', {
    method: 'POST',
    body: JSON.stringify({ email }),
  });
}
