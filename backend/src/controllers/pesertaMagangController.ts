import { type Request, type Response } from "express";
import { prisma } from "../lib/prisma";
import {
  sendSuccess,
  sendError,
  sendPaginatedSuccess,
} from "../utils/response";
import path from "path";
import fs from "fs";

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
        absensi: {
          orderBy: { createdAt: "desc" },
          take: 10, // Get last 10 attendance records
        },
        pengajuanIzin: {
          orderBy: { createdAt: "desc" },
          take: 5, // Get last 5 leave requests
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
      instansi,
      nomorHp,
      tanggalMulai,
      tanggalSelesai,
      status = "AKTIF",
      avatar,
    } = req.body;

    // Check if username already exists
    const existingPeserta = await prisma.pesertaMagang.findUnique({
      where: { username },
    });

    if (existingPeserta) {
      return sendError(res, "Username already exists", 400);
    }

    const pesertaMagang = await prisma.pesertaMagang.create({
      data: {
        nama,
        username,
        divisi,
        instansi,
        nomorHp,
        tanggalMulai,
        tanggalSelesai,
        status: status.toUpperCase(),
        avatar,
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
      nomorHp,
      tanggalMulai,
      tanggalSelesai,
      status,
      avatar,
    } = req.body;

    // Check if peserta magang exists
    const existingPeserta = await prisma.pesertaMagang.findUnique({
      where: { id },
    });

    if (!existingPeserta) {
      return sendError(res, "Peserta magang not found", 404);
    }

    // Check if username already exists (excluding current peserta)
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

    // Check if peserta magang exists and get avatar info
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

    // Delete avatar file if exists
    if (pesertaMagang.avatar) {
      try {
        // Extract filename from avatar URL
        const avatarUrl = pesertaMagang.avatar;
        const filename = path.basename(avatarUrl);
        const filePath = path.join(__dirname, "..", "uploads", filename);

        // Check if file exists and delete it
        if (fs.existsSync(filePath)) {
          fs.unlinkSync(filePath);
          console.log(`Avatar file deleted: ${filename}`);
        }
      } catch (fileError) {
        console.error("Error deleting avatar file:", fileError);
        // Continue with deletion even if file deletion fails
      }
    }

    // Delete peserta magang (this will cascade delete related absensi and pengajuanIzin)
    await prisma.pesertaMagang.delete({
      where: { id },
    });

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

    // Check if peserta magang exists and get current avatar
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

    // Delete old avatar file if exists
    if (existingPeserta.avatar) {
      try {
        // Extract filename from old avatar URL
        const oldAvatarUrl = existingPeserta.avatar;
        const oldFilename = path.basename(oldAvatarUrl);
        const oldFilePath = path.join(__dirname, "..", "uploads", oldFilename);

        // Check if old file exists and delete it
        if (fs.existsSync(oldFilePath)) {
          fs.unlinkSync(oldFilePath);
          console.log(`Old avatar file deleted: ${oldFilename}`);
        }
      } catch (fileError) {
        console.error("Error deleting old avatar file:", fileError);
        // Continue with upload even if old file deletion fails
      }
    }

    // Create avatar URL
    const avatarUrl = `http://localhost:3000/uploads/${file.filename}`;
    console.log("Avatar URL:", avatarUrl);

    // Update peserta magang with new avatar
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

export const removeAvatar = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;

    // Check if peserta magang exists and get current avatar
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

    // Delete physical file if avatar exists
    if (pesertaMagang.avatar) {
      try {
        // Extract filename from avatar URL
        const avatarUrl = pesertaMagang.avatar;
        const filename = path.basename(avatarUrl);
        const filePath = path.join(__dirname, "..", "uploads", filename);

        // Check if file exists and delete it
        if (fs.existsSync(filePath)) {
          fs.unlinkSync(filePath);
          console.log(`Avatar file deleted: ${filename}`);
        }
      } catch (fileError) {
        console.error("Error deleting avatar file:", fileError);
        // Continue with database update even if file deletion fails
      }
    }

    // Remove avatar from peserta magang
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
