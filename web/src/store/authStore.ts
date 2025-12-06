import { create } from 'zustand';
import type { Usuario } from '../types';

interface AuthState {
  user: Usuario | null;
  accessToken: string | null;
  isAuthenticated: boolean;
  login: (user: Usuario, accessToken: string, refreshToken: string) => void;
  logout: () => void;
  initializeAuth: () => void;
}

export const useAuthStore = create<AuthState>((set) => ({
  user: null,
  accessToken: null,
  isAuthenticated: false,

  login: (user, accessToken, refreshToken) => {
    localStorage.setItem('user', JSON.stringify(user));
    localStorage.setItem('accessToken', accessToken);
    localStorage.setItem('refreshToken', refreshToken);

    set({
      user,
      accessToken,
      isAuthenticated: true,
    });
  },

  logout: () => {
    localStorage.removeItem('user');
    localStorage.removeItem('accessToken');
    localStorage.removeItem('refreshToken');

    set({
      user: null,
      accessToken: null,
      isAuthenticated: false,
    });
  },

  initializeAuth: () => {
    const userStr = localStorage.getItem('user');
    const accessToken = localStorage.getItem('accessToken');

    if (userStr && accessToken) {
      try {
        const user = JSON.parse(userStr);
        set({
          user,
          accessToken,
          isAuthenticated: true,
        });
      } catch (error) {
        console.error('Error parsing user from localStorage:', error);
        localStorage.clear();
      }
    }
  },
}));
