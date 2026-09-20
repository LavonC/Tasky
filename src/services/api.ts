const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:3001';

export function getAuthHeaders(): Record<string, string> {
  const token = sessionStorage.getItem('tasky_token');

  return {
    'Content-Type': 'application/json',
    ...(token ? { Authorization: `Bearer ${token}` } : {}),
  };
}

export async function readApiResponse<T>(response: Response): Promise<T> {
  const text = await response.text();
  let data: unknown;

  try {
    data = text ? JSON.parse(text) : null;
  } catch {
    throw new Error(
      response.ok
        ? 'The server returned an invalid response.'
        : `Request failed (${response.status}): ${response.statusText || 'server error'}`,
    );
  }

  if (!response.ok) {
    const error = data as { error?: string; message?: string } | null;
    throw new Error(error?.error || error?.message || `Request failed (${response.status})`);
  }

  return data as T;
}

export { API_URL };
