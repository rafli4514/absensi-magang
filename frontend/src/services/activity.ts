import api from "../lib/api";
import type { ActivityLog } from "../types";

export const activityService = {
    getTimeline: (page = 1, limit = 20, userId?: string) => {
        const params: any = { page, limit };
        if (userId) params.userId = userId;
        return api.get<{
            data: ActivityLog[];
            pagination: {
                page: number;
                limit: number;
                total: number;
                totalPages: number;
            };
        }>("/activity", { params });
    },

    exportLogbook: (format: 'pdf' | 'csv', startDate: string, endDate: string, pesertaMagangId?: string) => {
        return api.get("/export/logbook", {
            params: { format, startDate, endDate, pesertaMagangId },
            responseType: "blob", // Important for file download
        });
    },

    exportActivity: (startDate: string, endDate: string) => {
        return api.get("/export/activity", {
            params: { startDate, endDate },
            responseType: "blob",
        });
    },
};
