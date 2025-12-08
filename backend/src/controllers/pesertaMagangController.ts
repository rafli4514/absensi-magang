import { type Request, type Response } from "express";
import { Role } from "@prisma/client";
import { prisma } from "../lib/prisma";
import {
sendSuccess,
sendError,
sendPaginatedSuccess,
} from "../utils/response";
import path from "path";
import fs from "fs";
import bcrypt from 'bcryptjs'; // Lebih rapi jika diimport di atas

export const getAllPesertaMagang = async (req: Request, res: Response) => {
try {
const page = parseInt(req.query.page as string) || 1;
const limit = parseInt(req.query.limit as string) || 10;
const skip = (page - 1) * limit;
const status = req.query.status as string;

const where: any = {};
if (status && status !== "Semua") {
      where.status = status.toUpperCase();
    }

    const [pesertaMagang, total] = await Promise.all([
      prisma.pesertaMagang.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: "desc" },
        include: {
          user: {
            select: {
              id: true,
              username: true,
              role: true,
              isActive: true,
            },
          },
        },
      }),
      prisma.pesertaMagang.count({ where }),
    ]);

    const totalPages = Math.ceil(total / limit);

    sendPaginatedSuccess(
      res,
      "Peserta magang retrieved successfully",
      pesertaMagang,
      { page, limit, total, totalPages }
    );
  } catch (error) {
    console.error("Get all peserta magang error:", error);
    sendError(res, "Failed to retrieve peserta magang");
  }
};

export const getPesertaMagangById = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const pesertaMagang = await prisma.pesertaMagang.findUnique({
      where: { id },
      include: {
        user: {
          select: {
            id: true,
            username: true,
            role: true,
            isActive: true,
          },
        },
        absensi: {
          orderBy: { createdAt: "desc" },
          take: 10,
        },
        pengajuanIzin: {
          orderBy: { createdAt: "desc" },
          take: 5,
        },
      },
    });

    if (!pesertaMagang) {
      return sendError(res, "Peserta magang not found", 404);
    }

    sendSuccess(res, "Peserta magang retrieved successfully", pesertaMagang);
  } catch (error) {
    console.error("Get peserta magang by ID error:", error);
    sendError(res, "Failed to retrieve peserta magang");
  }
};

export const createPesertaMagang = async (req: Request, res: Response) => {
  try {
    const {
      nama,
      username,
      divisi,
      instansi = "Universitas/Instansi Tidak Diketahui",
      id_instansi,
      nomorHp,
      tanggalMulai,
      tanggalSelesai,
      status = "AKTIF",
      avatar,
      password = "password123",
    } = req.body;

    if (!nama || !username || !divisi || !nomorHp || !tanggalMulai || !tanggalSelesai) {
      return sendError(res, "Required fields: nama, username, divisi, nomorHp, tanggalMulai, tanggalSelesai", 400);
    }

    const existingPeserta = await prisma.pesertaMagang.findUnique({
      where: { username },
    });

    if (existingPeserta) {
      return sendError(res, "Username already exists", 400);
    }

    const existingUser = await prisma.user.findUnique({
      where: { username },
    });

    if (existingUser) {
      return sendError(res, "Username already exists in users", 400);
    }

    const hashedPassword = await bcrypt.hash(password, 12);

    const user = await prisma.user.create({
      data: {
        username,
        password: hashedPassword,
        role: 'PESERTA_MAGANG',
        isActive: true,
      },
    });

    const pesertaMagang = await prisma.pesertaMagang.create({
      data: {
        nama,
        username,
        divisi,
        instansi,
        id_instansi,
        nomorHp,
        tanggalMulai,
        tanggalSelesai,
        status: status.toUpperCase(),
        avatar,
        userId: user.id,
      },
      include: {
        user: {
          select: {
            id: true,
            username: true,
            role: true,
            isActive: true,
          },
        },
      },
    });

    sendSuccess(res, "Peserta magang created successfully", pesertaMagang, 201);
  } catch (error) {
    console.error("Create peserta magang error:", error);
    sendError(res, "Failed to create peserta magang", 400);
  }
};

export const updatePesertaMagang = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const {
      nama,
      username,
      divisi,
      instansi,
      id_instansi,
      nomorHp,
      tanggalMulai,
      tanggalSelesai,
      status,
      avatar,
    } = req.body;

    const existingPeserta = await prisma.pesertaMagang.findUnique({
      where: { id },
    });

    if (!existingPeserta) {
      return sendError(res, "Peserta magang not found", 404);
    }

    if (username && username !== existingPeserta.username) {
      const duplicatePeserta = await prisma.pesertaMagang.findUnique({
        where: { username },
      });

      if (duplicatePeserta) {
        return sendError(res, "Username already exists", 400);
      }
    }

    const updateData: any = {};
    if (nama) updateData.nama = nama;
    if (username) updateData.username = username;
    if (divisi) updateData.divisi = divisi;
    if (instansi) updateData.instansi = instansi;
    if (id_instansi) updateData.id_instansi = id_instansi;
    if (nomorHp) updateData.nomorHp = nomorHp;
    if (tanggalMulai) updateData.tanggalMulai = tanggalMulai;
    if (tanggalSelesai) updateData.tanggalSelesai = tanggalSelesai;
    if (status) updateData.status = status.toUpperCase();
    if (avatar !== undefined) updateData.avatar = avatar;

    const updatedPesertaMagang = await prisma.pesertaMagang.update({
      where: { id },
      data: updateData,
    });

    sendSuccess(
      res,
      "Peserta magang updated successfully",
      updatedPesertaMagang
    );
  } catch (error) {
    console.error("Update peserta magang error:", error);
    sendError(res, "Failed to update peserta magang", 400);
  }
};

export const deletePesertaMagang = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;

    const pesertaMagang = await prisma.pesertaMagang.findUnique({
      where: { id },
      select: {
        id: true,
        avatar: true,
        userId: true,
      },
    });

    if (!pesertaMagang) {
      return sendError(res, "Peserta magang not found", 404);
    }

    if (pesertaMagang.avatar) {
      try {
        const avatarUrl = pesertaMagang.avatar;
        const filename = path.basename(avatarUrl);
        const filePath = path.join(__dirname, "..", "uploads", filename);

        if (fs.existsSync(filePath)) {
          fs.unlinkSync(filePath);
          console.log(`Avatar file deleted: ${filename}`);
        }
      } catch (fileError) {
        console.error("Error deleting avatar file:", fileError);
      }
    }

    await prisma.pesertaMagang.delete({
      where: { id },
    });

    if (pesertaMagang.userId) {
      try {
        await prisma.user.delete({
          where: { id: pesertaMagang.userId },
        });
        console.log(`Associated user deleted: ${pesertaMagang.userId}`);
      } catch (userError) {
        console.error("Error deleting associated user:", userError);
      }
    }

    sendSuccess(res, "Peserta magang deleted successfully");
  } catch (error) {
    console.error("Delete peserta magang error:", error);
    sendError(res, "Failed to delete peserta magang");
  }
};

export const uploadAvatar = async (req: Request, res: Response) => {
  try {
    console.log("Upload avatar request received");
    const { id } = req.params;
    const file = req.file;

    console.log("File received:", file);
    console.log("Peserta ID:", id);

    if (!file) {
      console.log("No file uploaded");
      return sendError(res, "No file uploaded", 400);
    }

    const existingPeserta = await prisma.pesertaMagang.findUnique({
      where: { id },
      select: {
        id: true,
        avatar: true,
      },
    });

    if (!existingPeserta) {
      console.log("Peserta magang not found:", id);
      return sendError(res, "Peserta magang not found", 404);
    }

    if (existingPeserta.avatar) {
      try {
        const oldAvatarUrl = existingPeserta.avatar;
        const oldFilename = path.basename(oldAvatarUrl);
        const oldFilePath = path.join(__dirname, "..", "uploads", oldFilename);

        if (fs.existsSync(oldFilePath)) {
          fs.unlinkSync(oldFilePath);
          console.log(`Old avatar file deleted: ${oldFilename}`);
        }
      } catch (fileError) {
        console.error("Error deleting old avatar file:", fileError);
      }
    }

    // Pastikan URL ini sesuai dengan environment (jangan localhost hardcoded jika untuk production)
    const avatarUrl = `http://localhost:3000/uploads/${file.filename}`;
    console.log("Avatar URL:", avatarUrl);

    const updatedPesertaMagang = await prisma.pesertaMagang.update({
      where: { id },
      data: { avatar: avatarUrl },
    });

    console.log("Avatar updated successfully");
    sendSuccess(res, "Avatar uploaded successfully", {
      pesertaMagang: updatedPesertaMagang,
      avatarUrl,
    });
  } catch (error) {
    console.error("Upload avatar error:", error);
    sendError(res, "Failed to upload avatar", 400);
  }
};

export const getPesertaMagangByUserId = async (req: Request, res: Response) => {
  try {
    const { userId } = req.params;
    const pesertaMagang = await prisma.pesertaMagang.findUnique({
      where: { userId },
      include: {
        user: {
          select: {
            id: true,
            username: true,
            role: true,
            isActive: true,
          },
        },
        absensi: {
          orderBy: { createdAt: "desc" },
          take: 10,
        },
        pengajuanIzin: {
          orderBy: { createdAt: "desc" },
          take: 5,
        },
      },
    });

    if (!pesertaMagang) {
      return sendError(res, "Peserta magang not found for this user", 404);
    }

    sendSuccess(res, "Peserta magang retrieved successfully", pesertaMagang);
  } catch (error) {
    console.error("Get peserta magang by user ID error:", error);
    sendError(res, "Failed to retrieve peserta magang");
  }
};

export const changePassword = async (req: Request, res: Response) => {
  try {
    const { currentPassword, newPassword } = req.body;
    const userId = req.user?.id;

    if (!userId) {
      return sendError(res, "User not authenticated", 401);
    }

    if (!currentPassword || !newPassword) {
      return sendError(res, "Current password and new password are required", 400);
    }

    if (newPassword.length < 6) {
      return sendError(res, "New password must be at least 6 characters", 400);
    }

    const user = await prisma.user.findUnique({
      where: { id: userId },
      include: {
        pesertaMagang: true,
      },
    });

    if (!user || !user.pesertaMagang) {
      return sendError(res, "Peserta magang not found", 404);
    }

    const isCurrentPasswordValid = await bcrypt.compare(currentPassword, user.password);
    if (!isCurrentPasswordValid) {
      return sendError(res, "Current password is incorrect", 400);
    }

    const hashedNewPassword = await bcrypt.hash(newPassword, 12);

    await prisma.user.update({
      where: { id: userId },
      data: { password: hashedNewPassword },
    });

    sendSuccess(res, "Password changed successfully");
  } catch (error) {
    console.error("Change password error:", error);
    sendError(res, "Failed to change password", 500);
  }
};

export const removeAvatar = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;

    const pesertaMagang = await prisma.pesertaMagang.findUnique({
      where: { id },
      select: {
        id: true,
        avatar: true,
      },
    });

    if (!pesertaMagang) {
      return sendError(res, "Peserta magang not found", 404);
    }

    if (pesertaMagang.avatar) {
      try {
        const avatarUrl = pesertaMagang.avatar;
        const filename = path.basename(avatarUrl);
        const filePath = path.join(__dirname, "..", "uploads", filename);

        if (fs.existsSync(filePath)) {
          fs.unlinkSync(filePath);
          console.log(`Avatar file deleted: ${filename}`);
        }
      } catch (fileError) {
        console.error("Error deleting avatar file:", fileError);
      }
    }

    const updatedPesertaMagang = await prisma.pesertaMagang.update({
      where: { id },
      data: { avatar: null },
    });

    sendSuccess(res, "Avatar removed successfully", updatedPesertaMagang);
  } catch (error) {
    console.error("Remove avatar error:", error);
    sendError(res, "Failed to remove avatar", 500);
  }
};