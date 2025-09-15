import { type Request, type Response } from 'express';
import { prisma } from '../lib/prisma';
import { sendSuccess, sendError } from '../utils/response';
import { generateToken } from '../utils/jwt';
import bcrypt from 'bcryptjs';
import fs from 'fs';
import path from 'path';

export const login = async (req: Request, res: Response) => {
  try {
    const { username, password } = req.body;

    if (!username || !password) {
      return sendError(res, 'Username and password are required', 400);
    }

    // Check if user exists
    const user = await prisma.user.findUnique({
      where: { username },
    });

    if (!user) {
      return sendError(res, 'Invalid credentials', 401);
    }

    // Check if user is active
    if (!user.isActive) {
      return sendError(res, 'Account is deactivated', 401);
    }

    // Verify password
    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      return sendError(res, 'Invalid credentials', 401);
    }

    // Generate JWT token
    const token = generateToken({
      id: user.id,
      username: user.username,
      role: user.role,
    });

    // Return user data without password
    const userResponse = {
      id: user.id,
      username: user.username,
      role: user.role,
      isActive: user.isActive,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    };

    sendSuccess(res, 'Login successful', {
      user: userResponse,
      token,
      expiresIn: '24h',
    });
  } catch (error) {
    console.error('Login error:', error);
    sendError(res, 'Login failed', 500);
  }
};

export const loginPesertaMagang = async (req: Request, res: Response) => {
  try {
    const { username, password } = req.body;

    if (!username || !password) {
      return sendError(res, 'Username and password are required', 400);
    }

    // Check if peserta magang exists
    const pesertaMagang = await prisma.pesertaMagang.findUnique({
      where: { username },
    });

    if (!pesertaMagang) {
      return sendError(res, 'Invalid credentials', 401);
    }

    // Check if peserta magang is active
    if (pesertaMagang.status !== 'AKTIF') {
      return sendError(res, 'Account is not active', 401);
    }

    // For now, we'll use a simple password check (you might want to hash passwords for peserta magang too)
    // This is a simplified version - in production, you should hash peserta magang passwords too
    if (password !== 'defaultPassword') { // You should implement proper password hashing
      return sendError(res, 'Invalid credentials', 401);
    }

    // Generate JWT token for peserta magang
    const token = generateToken({
      id: pesertaMagang.id,
      username: pesertaMagang.username,
      nama: pesertaMagang.nama,
      role: 'student',
      divisi: pesertaMagang.divisi,
    });

    sendSuccess(res, 'Login successful', {
      user: {
        id: pesertaMagang.id,
        nama: pesertaMagang.nama,
        username: pesertaMagang.username,
        role: 'student',
        divisi: pesertaMagang.divisi,
        universitas: pesertaMagang.universitas,
        avatar: pesertaMagang.avatar,
      },
      token,
      expiresIn: '24h',
    });
  } catch (error) {
    console.error('Peserta magang login error:', error);
    sendError(res, 'Login failed', 500);
  }
};

export const register = async (req: Request, res: Response) => {
  try {
    const { username, password, role = 'user' } = req.body;

    if (!username || !password) {
      return sendError(res, 'Username and password are required', 400);
    }

    // Check if user already exists
    const existingUser = await prisma.user.findFirst({
      where: {
        username,
      },
    });

    if (existingUser) {
      return sendError(res, 'Username already exists', 400);
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 12);

    // Create new user
    const user = await prisma.user.create({
      data: {
        username,
        password: hashedPassword,
        role: role.toUpperCase(),
        isActive: true,
      },
      select: {
        id: true,
        username: true,
        role: true,
        isActive: true,
        createdAt: true,
        updatedAt: true,
      },
    });

    // Generate JWT token
    const token = generateToken({
      id: user.id,
      username: user.username,
      role: user.role,
    });

    sendSuccess(res, 'Registration successful', {
      user,
      token,
      expiresIn: '24h',
    }, 201);
  } catch (error) {
    console.error('Registration error:', error);
    sendError(res, 'Registration failed', 500);
  }
};

export const getProfile = async (req: Request, res: Response) => {
  try {
    const userId = req.user?.id;

    if (!userId) {
      return sendError(res, 'User not authenticated', 401);
    }

    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        username: true,
        role: true,
        isActive: true,
        avatar: true,
        createdAt: true,
        updatedAt: true,
      },
    });

    if (!user) {
      return sendError(res, 'User not found', 404);
    }

    sendSuccess(res, 'Profile retrieved successfully', user);
  } catch (error) {
    console.error('Get profile error:', error);
    sendError(res, 'Failed to get profile', 500);
  }
};

export const updateProfile = async (req: Request, res: Response) => {
  try {
    const userId = req.user?.id;
    const { username, currentPassword, newPassword } = req.body;

    if (!userId) {
      return sendError(res, 'User not authenticated', 401);
    }

    const user = await prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user) {
      return sendError(res, 'User not found', 404);
    }

    // Check if username already exists (excluding current user)
    if (username) {
      const existingUser = await prisma.user.findFirst({
        where: {
          AND: [
            { id: { not: userId } },
            { username },
          ],
        },
      });

      if (existingUser) {
        return sendError(res, 'Username already exists', 400);
      }
    }

    const updateData: any = {};
    if (username) updateData.username = username;

    // Handle password change
    if (newPassword) {
      if (!currentPassword) {
        return sendError(res, 'Current password is required to change password', 400);
      }

      const isCurrentPasswordValid = await bcrypt.compare(currentPassword, user.password);
      if (!isCurrentPasswordValid) {
        return sendError(res, 'Current password is incorrect', 400);
      }

      updateData.password = await bcrypt.hash(newPassword, 12);
    }

    const updatedUser = await prisma.user.update({
      where: { id: userId },
      data: updateData,
      select: {
        id: true,
        username: true,
        role: true,
        isActive: true,
        avatar: true,
        createdAt: true,
        updatedAt: true,
      },
    });

    sendSuccess(res, 'Profile updated successfully', updatedUser);
  } catch (error) {
    console.error('Update profile error:', error);
    sendError(res, 'Failed to update profile', 500);
  }
};

export const uploadAvatar = async (req: Request, res: Response) => {
  try {
    const userId = req.user?.id;
    const file = req.file;

    if (!userId) {
      return sendError(res, 'User not authenticated', 401);
    }

    if (!file) {
      return sendError(res, 'No file uploaded', 400);
    }

    // Check if user exists and get current avatar
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        avatar: true,
      },
    });

    if (!user) {
      return sendError(res, 'User not found', 404);
    }

    // Delete old avatar file if exists
    if (user.avatar) {
      try {
        // Extract filename from old avatar URL
        const oldAvatarUrl = user.avatar;
        const oldFilename = path.basename(oldAvatarUrl);
        const oldFilePath = path.join(__dirname, '..', 'uploads', oldFilename);

        // Check if old file exists and delete it
        if (fs.existsSync(oldFilePath)) {
          fs.unlinkSync(oldFilePath);
          console.log(`Old avatar file deleted: ${oldFilename}`);
        }
      } catch (fileError) {
        console.error('Error deleting old avatar file:', fileError);
        // Continue with upload even if old file deletion fails
      }
    }

    // Create avatar URL
    const avatarUrl = `http://localhost:3000/uploads/${file.filename}`;

    // Update user with new avatar
    const updatedUser = await prisma.user.update({
      where: { id: userId },
      data: { avatar: avatarUrl },
      select: {
        id: true,
        username: true,
        role: true,
        isActive: true,
        avatar: true,
        createdAt: true,
        updatedAt: true,
      },
    });

    sendSuccess(res, 'Avatar uploaded successfully', {
      user: updatedUser,
      avatarUrl,
    });
  } catch (error) {
    console.error('Upload avatar error:', error);
    sendError(res, 'Failed to upload avatar', 500);
  }
};

export const removeAvatar = async (req: Request, res: Response) => {
  try {
    const userId = req.user?.id;

    if (!userId) {
      return sendError(res, 'User not authenticated', 401);
    }

    // Check if user exists and get current avatar
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        avatar: true,
      },
    });

    if (!user) {
      return sendError(res, 'User not found', 404);
    }

    // Delete physical file if avatar exists
    if (user.avatar) {
      try {
        // Extract filename from avatar URL
        const avatarUrl = user.avatar;
        const filename = path.basename(avatarUrl);
        const filePath = path.join(__dirname, '..', 'uploads', filename);

        // Check if file exists and delete it
        if (fs.existsSync(filePath)) {
          fs.unlinkSync(filePath);
          console.log(`Avatar file deleted: ${filename}`);
        }
      } catch (fileError) {
        console.error('Error deleting avatar file:', fileError);
        // Continue with database update even if file deletion fails
      }
    }

    // Remove avatar from user
    const updatedUser = await prisma.user.update({
      where: { id: userId },
      data: { avatar: null },
      select: {
        id: true,
        username: true,
        role: true,
        isActive: true,
        avatar: true,
        createdAt: true,
        updatedAt: true,
      },
    });

    sendSuccess(res, 'Avatar removed successfully', updatedUser);
  } catch (error) {
    console.error('Remove avatar error:', error);
    sendError(res, 'Failed to remove avatar', 500);
  }
};

export const refreshToken = async (req: Request, res: Response) => {
  try {
    const userId = req.user?.id;

    if (!userId) {
      return sendError(res, 'User not authenticated', 401);
    }

    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        username: true,
        role: true,
        isActive: true,
      },
    });

    if (!user) {
      return sendError(res, 'User not found', 404);
    }

    if (!user.isActive) {
      return sendError(res, 'Account is deactivated', 401);
    }

    // Generate new JWT token
    const token = generateToken({
      id: user.id,
      username: user.username,
      role: user.role,
    });

    sendSuccess(res, 'Token refreshed successfully', {
      token,
      expiresIn: '24h',
    });
  } catch (error) {
    console.error('Refresh token error:', error);
    sendError(res, 'Failed to refresh token', 500);
  }
};