import { type Request, type Response } from 'express';
import { prisma } from '../lib/prisma';
import { sendSuccess, sendError, sendPaginatedSuccess } from '../utils/response';
import bcrypt from 'bcryptjs';

export const getAllUsers = async (req: Request, res: Response) => {
  try {
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 10;
    const skip = (page - 1) * limit;
    const role = req.query.role as string;
    const isActive = req.query.isActive as string;

    const where: any = {};
    if (role) {
      where.role = role.toUpperCase();
    }
    if (isActive !== undefined) {
      where.isActive = isActive === 'true';
    }

    const [users, total] = await Promise.all([
      prisma.user.findMany({
        where,
        select: {
          id: true,
          username: true,
          role: true,
          isActive: true,
          createdAt: true,
          updatedAt: true,
        },
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
      }),
      prisma.user.count({ where }),
    ]);

    const totalPages = Math.ceil(total / limit);

    sendPaginatedSuccess(
      res,
      'Users retrieved successfully',
      users,
      { page, limit, total, totalPages }
    );
  } catch (error) {
    console.error('Get all users error:', error);
    sendError(res, 'Failed to retrieve users');
  }
};

export const getUserById = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const user = await prisma.user.findUnique({
      where: { id },
      select: {
        id: true,
        username: true,
        role: true,
        isActive: true,
        createdAt: true,
        updatedAt: true,
      },
    });

    if (!user) {
      return sendError(res, 'User not found', 404);
    }

    sendSuccess(res, 'User retrieved successfully', user);
  } catch (error) {
    console.error('Get user by ID error:', error);
    sendError(res, 'Failed to retrieve user');
  }
};

export const createUser = async (req: Request, res: Response) => {
  try {
    const { username, password, role = 'peserta_magang', isActive = true } = req.body;

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

    const user = await prisma.user.create({
      data: {
        username,
        password: hashedPassword,
        role: role.toUpperCase(),
        isActive,
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

    sendSuccess(res, 'User created successfully', user, 201);
  } catch (error) {
    console.error('Create user error:', error);
    sendError(res, 'Failed to create user', 400);
  }
};

export const updateUser = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const { username, password, role, isActive } = req.body;

    // Check if user exists
    const existingUser = await prisma.user.findUnique({
      where: { id },
    });

    if (!existingUser) {
      return sendError(res, 'User not found', 404);
    }

    // Check if username already exists (excluding current user)
    if (username) {
      const duplicateUser = await prisma.user.findFirst({
        where: {
          AND: [
            { id: { not: id } },
            { username },
          ],
        },
      });

      if (duplicateUser) {
        return sendError(res, 'Username already exists', 400);
      }
    }

    const updateData: any = {};
    if (username) updateData.username = username;
    if (role) updateData.role = role.toUpperCase();
    if (isActive !== undefined) updateData.isActive = isActive;
    if (password) {
      updateData.password = await bcrypt.hash(password, 12);
    }

    const updatedUser = await prisma.user.update({
      where: { id },
      data: updateData,
      select: {
        id: true,
        username: true,
        role: true,
        isActive: true,
        createdAt: true,
        updatedAt: true,
      },
    });

    sendSuccess(res, 'User updated successfully', updatedUser);
  } catch (error) {
    console.error('Update user error:', error);
    sendError(res, 'Failed to update user', 400);
  }
};

export const deleteUser = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;

    // Check if user exists
    const user = await prisma.user.findUnique({
      where: { id },
    });

    if (!user) {
      return sendError(res, 'User not found', 404);
    }

    // Prevent deleting own account
    if (req.user && req.user.id === id) {
      return sendError(res, 'Cannot delete your own account', 400);
    }

    await prisma.user.delete({
      where: { id },
    });

    sendSuccess(res, 'User deleted successfully');
  } catch (error) {
    console.error('Delete user error:', error);
    sendError(res, 'Failed to delete user');
  }
};

export const toggleUserStatus = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;

    const user = await prisma.user.findUnique({
      where: { id },
    });

    if (!user) {
      return sendError(res, 'User not found', 404);
    }

    // Prevent deactivating own account
    if (req.user && req.user.id === id) {
      return sendError(res, 'Cannot deactivate your own account', 400);
    }

    const updatedUser = await prisma.user.update({
      where: { id },
      data: { isActive: !user.isActive },
      select: {
        id: true,
        username: true,
        role: true,
        isActive: true,
        createdAt: true,
        updatedAt: true,
      },
    });

    sendSuccess(
      res,
      `User ${updatedUser.isActive ? 'activated' : 'deactivated'} successfully`,
      updatedUser
    );
  } catch (error) {
    console.error('Toggle user status error:', error);
    sendError(res, 'Failed to toggle user status');
  }
};