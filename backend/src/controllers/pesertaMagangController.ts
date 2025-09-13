import { type Request, type Response } from 'express';
import PesertaMagang from '../models/PesertaMagang';
import { sendSuccess, sendError, sendPaginatedSuccess } from '../utils/response';
import type { PesertaMagang as PesertaMagangType } from '../types';

export const getAllPesertaMagang = async (req: Request, res: Response) => {
  try {
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 10;
    const offset = (page - 1) * limit;

    const { rows: pesertaMagang, count: total } = await PesertaMagang.findAndCountAll({
      limit,
      offset,
      order: [['createdAt', 'DESC']],
    });

    const totalPages = Math.ceil(total / limit);

    sendPaginatedSuccess(
      res,
      'Peserta magang retrieved successfully',
      pesertaMagang as any,
      { page, limit, total, totalPages }
    );
  } catch (error) {
    sendError(res, 'Failed to retrieve peserta magang');
  }
};

export const getPesertaMagangById = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const pesertaMagang = await PesertaMagang.findByPk(id);

    if (!pesertaMagang) {
      return sendError(res, 'Peserta magang not found', 404);
    }

    sendSuccess(res, 'Peserta magang retrieved successfully', pesertaMagang as any);
  } catch (error) {
    sendError(res, 'Failed to retrieve peserta magang');
  }
};

export const createPesertaMagang = async (req: Request, res: Response) => {
  try {
    const pesertaMagangData = req.body;
    const pesertaMagang = await PesertaMagang.create(pesertaMagangData);

    sendSuccess(res, 'Peserta magang created successfully', pesertaMagang as any, 201);
  } catch (error) {
    sendError(res, 'Failed to create peserta magang', 400);
  }
};

export const updatePesertaMagang = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const updateData = req.body;

    const [updatedRowsCount] = await PesertaMagang.update(updateData, {
      where: { id },
    });

    if (updatedRowsCount === 0) {
      return sendError(res, 'Peserta magang not found', 404);
    }

    const updatedPesertaMagang = await PesertaMagang.findByPk(id);
    sendSuccess(res, 'Peserta magang updated successfully', updatedPesertaMagang as any);
  } catch (error) {
    sendError(res, 'Failed to update peserta magang', 400);
  }
};

export const deletePesertaMagang = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const deletedRowsCount = await PesertaMagang.destroy({
      where: { id },
    });

    if (deletedRowsCount === 0) {
      return sendError(res, 'Peserta magang not found', 404);
    }

    sendSuccess(res, 'Peserta magang deleted successfully');
  } catch (error) {
    sendError(res, 'Failed to delete peserta magang');
  }
};
