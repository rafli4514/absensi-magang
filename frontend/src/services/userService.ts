import api from '../lib/api';

export interface CreateUserRequest {
  username: string;
  password: string;
  role: 'ADMIN' | 'PESERTA_MAGANG' | 'PEMBIMBING_MAGANG';
  isActive?: boolean;
}

export interface UpdateUserRequest {
  username?: string;
  password?: string;
  role?: 'ADMIN' | 'PESERTA_MAGANG' | 'PEMBIMBING_MAGANG';
  isActive?: boolean;
}

export interface UserFilters {
  page?: number;
  limit?: number;
  role?: string;
  isActive?: string;
  search?: string;
}

const userService = {
  // Get all users with filters
  async getUsers(filters: UserFilters = {}) {
    const params = new URLSearchParams();
    
    if (filters.page) params.append('page', filters.page.toString());
    if (filters.limit) params.append('limit', filters.limit.toString());
    if (filters.role) params.append('role', filters.role);
    if (filters.isActive) params.append('isActive', filters.isActive);
    if (filters.search) params.append('search', filters.search);

    const response = await api.get(`/users?${params.toString()}`);
    return response.data;
  },

  // Get user by ID
  async getUserById(id: string) {
    const response = await api.get(`/users/${id}`);
    return response.data;
  },

  // Create new user
  async createUser(userData: CreateUserRequest) {
    const response = await api.post('/users', userData);
    return response.data;
  },

  // Update user
  async updateUser(id: string, userData: UpdateUserRequest) {
    const response = await api.put(`/users/${id}`, userData);
    return response.data;
  },

  // Delete user
  async deleteUser(id: string) {
    const response = await api.delete(`/users/${id}`);
    return response.data;
  },

  // Toggle user status
  async toggleUserStatus(id: string) {
    const response = await api.patch(`/users/${id}/toggle-status`);
    return response.data;
  },
};

export default userService;
