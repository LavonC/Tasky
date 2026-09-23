export function getThemeStorageKey(userId?: string | null): string {
  return userId ? `tasky_dark_mode_${userId}` : 'tasky_dark_mode';
}

export function getStoredUserId(): string | null {
  const savedUser = sessionStorage.getItem('tasky_user');
  if (!savedUser) return null;

  try {
    return JSON.parse(savedUser).id || null;
  } catch {
    return null;
  }
}