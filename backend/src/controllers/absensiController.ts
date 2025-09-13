import { type Request, type Response } from 'express';
import Absensi from '../models/Absensi';
import PesertaMagang from '../models/PesertaMagang';
import { sendSuccess, sendError, sendPaginatedSuccess } from '../utils/response';
import type { Absensi as AbsensiType } from '../types';

export const getAllAbsensi = async (req: Request, res: Response) => {
  try {
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 10;
    const offset = (page - 1) * limit;
    const pesertaMagangId = req.query.pesertaMagangId as string;

    const whereClause: any = {};
    if (pesertaMagangId) {
      whereClause.pesertaMagangId = pesertaMagangId;
    }

    const { rows: absensi, count: total } = await Absensi.findAndCountAll({
      where: whereClause,
      include: [{
        model: PesertaMagang,
        as: 'pesertaMagang',
        attributes: ['id', 'nama', 'username', 'divisi'],
      }],
      limit,
      offset,
      order: [['createdAt', 'DESC']],
    });

    const totalPages = Math.ceil(total / limit);

    sendPaginatedSuccess(
      res,
      'Absensi retrieved successfully',
      absensi as any,
      { page, limit, total, totalPages }
    );
  } catch (error) {
    sendError(res, 'Failed to retrieve absensi');
  }
};

export const getAbsensiById = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const absensi = await Absensi.findByPk(id, {
      include: [{
        model: PesertaMagang,
        as: 'pesertaMagang',
        attributes: ['id', 'nama', 'username', 'divisi'],
      }],
    });

    if (!absensi) {
      return sendError(res, 'Absensi not found', 404);
    }

    sendSuccess(res, 'Absensi retrieved successfully', absensi as any);
  } catch (error) {
    sendError(res, 'Failed to retrieve absensi');
  }
};

export const createAbsensi = async (req: Request, res: Response) => {
  try {
    const absensiData = req.body;

    // Validate peserta magang exists
    const pesertaMagang = await PesertaMagang.findByPk(absensiData.pesertaMagangId);
    if (!pesertaMagang) {
      return sendError(res, 'Peserta magang not found', 400);
    }

    const absensi = await Absensi.create(absensiData);
    const absensiWithPeserta = await Absensi.findByPk(absensi.id, {
      include: [{
        model: PesertaMagang,
        as: 'pesertaMagang',
        attributes: ['id', 'nama', 'username', 'divisi'],
      }],
    });

    sendSuccess(res, 'Absensi created successfully', absensiWithPeserta as any, 201);
  } catch (error) {
    sendError(res, 'Failed to create absensi', 400);
  }
};

export const updateAbsensi = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const updateData = req.body;

    const [updatedRowsCount] = await Absensi.update(updateData, {
      where: { id },
    });

    if (updatedRowsCount === 0) {
      return sendError(res, 'Absensi not found', 404);
    }

    const updatedAbsensi = await Absensi.findByPk(id, {
      include: [{
        model: PesertaMagang,
        as: 'pesertaMagang',
        attributes: ['id', 'nama', 'username', 'divisi'],
      }],
    });

    sendSuccess(res, 'Absensi updated successfully', updatedAbsensi as any);
  } catch (error) {
    sendError(res, 'Failed to update absensi', 400);
  }
};

export const deleteAbsensi = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const deletedRowsCount = await Absensi.destroy({
      where: { id },
    });

    if (deletedRowsCount === 0) {
      return sendError(res, 'Absensi not found', 404);
    }

    sendSuccess(res, 'Absensi deleted successfully');
  } catch (error) {
    sendError(res, 'Failed to delete absensi');
  }
};
