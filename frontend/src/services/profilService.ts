import api from '../lib/api';
import type { User } from '../types';

export interface UpdateProfileRequest {
  username?: string;
  currentPassword?: string;
  newPassword?: string;
}

export interface ApiResponse<T = any> {
  success: boolean;
  message: string;
  data?: T;
  error?: string;
}

export interface AvatarUploadResponse {
  success: boolean;
  message: string;
  data: {
    avatarUrl: string;
  };
}

class ProfilService {
  /**
   * Get current user profile
   */
  async getProfile(): Promise<ApiResponse<User>> {
    try {
      const response = await api.get<ApiResponse<User>>('/auth/profile');
      return response.data;
    } catch (error: any) {
      throw new Error(error.response?.data?.message || 'Failed to get profile');
    }
  }

  /**
   * Update user profile
   */
  async updateProfile(data: UpdateProfileRequest): Promise<ApiResponse<User>> {
    try {
      const response = await api.put<ApiResponse<User>>('/auth/profile', data);
      
      // Update local storage with new user data
      if (response.data.success && response.data.data) {
        const currentUser = JSON.parse(localStorage.getItem('user') || '{}');
        const updatedUser = { ...currentUser, ...response.data.data };
        localStorage.setItem('user', JSON.stringify(updatedUser));
      }
      
      return response.data;
    } catch (error: any) {
      throw new Error(error.response?.data?.message || 'Failed to update profile');
    }
  }

  /**
   * Change password
   */
  async changePassword(currentPassword: string, newPassword: string): Promise<ApiResponse> {
    try {
      const response = await api.put<ApiResponse>('/auth/profile', {
        currentPassword,
        newPassword
      });
      return response.data;
    } catch (error: any) {
      throw new Error(error.response?.data?.message || 'Failed to change password');
    }
  }

  /**
   * Upload avatar (if avatar upload is implemented in backend)
   */
  async uploadAvatar(file: File): Promise<AvatarUploadResponse> {
    try {
      const formData = new FormData();
      formData.append('avatar', file);

      const response = await api.post<AvatarUploadResponse>('/auth/upload-avatar', formData, {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      });

      // Update local storage with new avatar URL
      if (response.data.success && response.data.data) {
        const currentUser = JSON.parse(localStorage.getItem('user') || '{}');
        const updatedUser = { ...currentUser, avatar: response.data.data.avatarUrl };
        localStorage.setItem('user', JSON.stringify(updatedUser));
      }

      return response.data;
    } catch (error: any) {
      throw new Error(error.response?.data?.message || 'Failed to upload avatar');
    }
  }

  /**
   * Remove avatar
   */
  async removeAvatar(): Promise<ApiResponse> {
    try {
      const response = await api.delete<ApiResponse>('/auth/avatar');
      
      // Update local storage to remove avatar
      if (response.data.success) {
        const currentUser = JSON.parse(localStorage.getItem('user') || '{}');
        const updatedUser = { ...currentUser, avatar: null };
        localStorage.setItem('user', JSON.stringify(updatedUser));
      }
      
      return response.data;
    } catch (error: any) {
      throw new Error(error.response?.data?.message || 'Failed to remove avatar');
    }
  }

  /**
   * Get current user from localStorage
   */
  getCurrentUser(): User | null {
    const userStr = localStorage.getItem('user');
    if (userStr) {
      try {
        return JSON.parse(userStr);
      } catch (error) {
        console.error('Error parsing user data:', error);
        return null;
      }
    }
    return null;
  }

  /**
   * Validate password strength
   */
  validatePassword(password: string): { isValid: boolean; message: string } {
    if (password.length < 8) {
      return { isValid: false, message: 'Password minimal 8 karakter' };
    }
    if (!/(?=.*[a-z])(?=.*[A-Z])/.test(password)) {
      return { isValid: false, message: 'Password harus mengandung huruf besar dan kecil' };
    }
    if (!/(?=.*\d)/.test(password)) {
      return { isValid: false, message: 'Password harus mengandung angka' };
    }
    return { isValid: true, message: 'Password valid' };
  }

  /**
   * Validate email format
   */
  validateEmail(email: string): { isValid: boolean; message: string } {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      return { isValid: false, message: 'Format email tidak valid' };
    }
    return { isValid: true, message: 'Email valid' };
  }

  /**
   * Validate username
   */
  validateUsername(username: string): { isValid: boolean; message: string } {
    if (username.length < 3) {
      return { isValid: false, message: 'Username minimal 3 karakter' };
    }
    if (!/^[a-zA-Z0-9_]+$/.test(username)) {
      return { isValid: false, message: 'Username hanya boleh mengandung huruf, angka, dan underscore' };
    }
    return { isValid: true, message: 'Username valid' };
  }
}

export default new ProfilService();
