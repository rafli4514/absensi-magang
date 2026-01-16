import api from '../lib/api';

export interface Pembimbing {
    id: string;
    nama: string;
    bidang: string;
    kuota: number;
}

const getPembimbings = async (bidang?: string) => {
    const params = bidang ? { bidang } : {};
    const response = await api.get<{ success: boolean; data: Pembimbing[] }>('/pembimbing', { params });
    return response.data;
};

const getBidangList = async () => {
    const response = await api.get<{ success: boolean; data: string[] }>('/pembimbing/bidang');
    return response.data;
}

export default {
    getPembimbings,
    getBidangList
};
