import { useState, useEffect } from "react";
import type { PengajuanIzin } from "../../types/index";
import pengajuanIzinService from "../../services/pengajuanIzinService";
import {
  Box,
  Button,
  Card,
  Dialog,
  Flex,
  Select,
  Table,
  TextField,
  Text,
  Grid,
  IconButton,
  Separator,
  AlertDialog
} from "@radix-ui/themes";
import {
  EyeOpenIcon,
  FileTextIcon,
  CalendarIcon,
  MixerHorizontalIcon,
  CheckCircledIcon,
  CrossCircledIcon,
  TrashIcon,
  PersonIcon,
  ExternalLinkIcon,
  DoubleArrowLeftIcon,
  ChevronLeftIcon,
  ChevronRightIcon,
  DoubleArrowRightIcon
} from "@radix-ui/react-icons";
import Avatar from "../Avatar";

const StatusBadge = ({ status }: { status: PengajuanIzin["status"] }) => {
  const statusConfig: Record<string, { color: string; label: string }> = {
    PENDING: { color: "bg-yellow-100 text-yellow-800", label: "Menunggu" },
    DISETUJUI: { color: "bg-green-100 text-green-800", label: "Disetujui" },
    DITOLAK: { color: "bg-red-100 text-red-800", label: "Ditolak" },
  };
  
  const config = statusConfig[status] || { color: "bg-gray-100 text-gray-800", label: status };
  
  return (
    <span className={`inline-flex px-2 py-0.5 text-[10px] font-semibold rounded-full ${config.color}`}>
      {config.label}
    </span>
  );
};

const TypeBadge = ({ tipe }: { tipe: PengajuanIzin["tipe"] }) => {
  const typeConfig: Record<string, { color: string; label: string }> = {
    SAKIT: { color: "bg-red-50 text-red-600 border-red-200", label: "Sakit" },
    IZIN: { color: "bg-blue-50 text-blue-600 border-blue-200", label: "Izin" },
    CUTI: { color: "bg-purple-50 text-purple-600 border-purple-200", label: "Cuti" },
  };

  const config = typeConfig[tipe] || { color: "bg-gray-50 text-gray-600 border-gray-200", label: tipe };
  
  return (
    <span className={`inline-flex px-2 py-0.5 text-[10px] font-semibold rounded-full border ${config.color}`}>
      {config.label}
    </span>
  );
};

export default function IzinList() {
  const [pengajuanIzin, setPengajuanIzin] = useState<PengajuanIzin[]>([]);
  const [loading, setLoading] = useState(true);
  
  // Filters
  const [searchTerm, setSearchTerm] = useState("");
  const [statusFilter, setStatusFilter] = useState<string>("Semua");
  const [typeFilter, setTypeFilter] = useState<string>("Semua");

  // Pagination
  const [currentPage, setCurrentPage] = useState(1);
  const itemsPerPage = 10;

  // Actions State
  const [deleteId, setDeleteId] = useState<string | null>(null);

  useEffect(() => {
    fetchIzin();
  }, []);

  const fetchIzin = async () => {
    try {
      setLoading(true);
      const response = await pengajuanIzinService.getAll({ limit: 1000 });
      if (response.success && response.data) {
        setPengajuanIzin(response.data);
      }
    } catch (error) {
      console.error("Gagal mengambil data izin:", error);
    } finally {
      setLoading(false);
    }
  };

  const filteredPengajuanIzin = pengajuanIzin.filter((item) => {
    const matchesSearch = item.pesertaMagang?.nama.toLowerCase().includes(searchTerm.toLowerCase()) || item.alasan.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesStatus = statusFilter === "Semua" || item.status === statusFilter;
    const matchesType = typeFilter === "Semua" || item.tipe === typeFilter;
    return matchesSearch && matchesStatus && matchesType;
  });

  // Pagination Logic
  const totalItems = filteredPengajuanIzin.length;
  const totalPages = Math.ceil(totalItems / itemsPerPage);
  const paginatedData = filteredPengajuanIzin.slice(
    (currentPage - 1) * itemsPerPage,
    currentPage * itemsPerPage
  );

  useEffect(() => { setCurrentPage(1); }, [searchTerm, statusFilter, typeFilter]);

  // Actions
  const handleApprove = async (id: string) => {
    try {
      await pengajuanIzinService.approve(id, "Disetujui oleh Admin");
      // Optimistic Update
      setPengajuanIzin(prev => prev.map(item => item.id === id ? { ...item, status: "DISETUJUI" } : item));
    } catch (error) {
      console.error("Error approving:", error);
      alert("Gagal menyetujui izin");
    }
  };

  const handleReject = async (id: string) => {
    try {
      await pengajuanIzinService.reject(id, "Ditolak oleh Admin");
      // Optimistic Update
      setPengajuanIzin(prev => prev.map(item => item.id === id ? { ...item, status: "DITOLAK" } : item));
    } catch (error) {
      console.error("Error rejecting:", error);
      alert("Gagal menolak izin");
    }
  };

  const handleDelete = async () => {
    if (!deleteId) return;
    try {
      await pengajuanIzinService.delete(deleteId);
      setPengajuanIzin(prev => prev.filter(item => item.id !== deleteId));
      setDeleteId(null);
    } catch (error) {
        console.error("Error deleting:", error);
        alert("Gagal menghapus data. Pastikan fitur hapus tersedia di server.");
    }
  };

  const stats = {
    total: pengajuanIzin.length,
    pending: pengajuanIzin.filter((p) => p.status === "PENDING").length,
    disetujui: pengajuanIzin.filter((p) => p.status === "DISETUJUI").length,
    ditolak: pengajuanIzin.filter((p) => p.status === "DITOLAK").length,
  };

  const renderPaginationButtons = () => {
    const buttons = [];
    const maxVisiblePages = 5;
    let startPage = Math.max(1, currentPage - Math.floor(maxVisiblePages / 2));
    const endPage = Math.min(totalPages, startPage + maxVisiblePages - 1);
    if (endPage - startPage + 1 < maxVisiblePages) startPage = Math.max(1, endPage - maxVisiblePages + 1);

    for (let i = startPage; i <= endPage; i++) {
      buttons.push(
        <Button key={i} size="1" variant={currentPage === i ? "solid" : "soft"} color={currentPage === i ? "indigo" : "gray"} onClick={() => setCurrentPage(i)} className="w-8 h-8 p-0 cursor-pointer">{i}</Button>
      );
    }
    return buttons;
  };

  if (loading) return <div className="p-10 text-center text-gray-500">Memuat data izin...</div>;

  return (
    <div className="space-y-4">
      {/* Compact Statistics */}
      <Grid columns={{ initial: "2", md: "4" }} gap="3">
        {[
          { label: "Total Izin", value: stats.total, sub: "Total permohonan", color: "text-gray-900", bg: "bg-white" },
          { label: "Menunggu", value: stats.pending, sub: "Perlu ditinjau", color: "text-orange-600", bg: "bg-orange-50/50" },
          { label: "Disetujui", value: stats.disetujui, sub: "Izin diterima", color: "text-green-600", bg: "bg-green-50/50" },
          { label: "Ditolak", value: stats.ditolak, sub: "Izin ditolak", color: "text-red-600", bg: "bg-red-50/50" },
        ].map((stat, idx) => (
          <Card key={idx} className={`${stat.bg} shadow-sm border border-gray-100`}>
            <Flex direction="column" p="3">
              <Text size="1" weight="medium" color="gray" className="uppercase tracking-wider">{stat.label}</Text>
              <Text size="6" weight="bold" className={`my-0.5 ${stat.color}`}>{stat.value}</Text>
              <Text size="1" color="gray" className="text-[10px]">{stat.sub}</Text>
            </Flex>
          </Card>
        ))}
      </Grid>

      {/* Filters */}
      <Card className="shadow-sm">
        <Box p="3">
          <Flex direction="column" gap="3">
            <Flex gap="3" wrap="wrap" align="center" justify="between">
              <div className="flex-1 min-w-[200px]">
                <TextField.Root size="2" color="indigo" placeholder="Cari izin..." value={searchTerm} onChange={(e) => setSearchTerm(e.target.value)} className="w-full" radius="large">
                  <TextField.Slot><MixerHorizontalIcon height="14" width="14" /></TextField.Slot>
                </TextField.Root>
              </div>
              <Flex gap="2">
                <Select.Root size="2" defaultValue="Semua" value={statusFilter} onValueChange={setStatusFilter}>
                  <Select.Trigger color="indigo" radius="large" className="min-w-[120px]" placeholder="Status" />
                  <Select.Content color="indigo">
                    <Select.Item value="Semua">Semua Status</Select.Item>
                    <Select.Item value="PENDING">Menunggu</Select.Item>
                    <Select.Item value="DISETUJUI">Disetujui</Select.Item>
                    <Select.Item value="DITOLAK">Ditolak</Select.Item>
                  </Select.Content>
                </Select.Root>
                <Select.Root size="2" defaultValue="Semua" value={typeFilter} onValueChange={setTypeFilter}>
                  <Select.Trigger color="indigo" radius="large" className="min-w-[120px]" placeholder="Jenis" />
                  <Select.Content color="indigo">
                    <Select.Item value="Semua">Semua Jenis</Select.Item>
                    <Select.Item value="SAKIT">Sakit</Select.Item>
                    <Select.Item value="IZIN">Izin</Select.Item>
                    <Select.Item value="CUTI">Cuti</Select.Item>
                  </Select.Content>
                </Select.Root>
              </Flex>
            </Flex>
          </Flex>
        </Box>
      </Card>

      {/* Table */}
      <Card className="shadow-sm overflow-hidden">
        <Flex direction="row" justify="between" align="center" className="border-b border-gray-100 bg-gray-50/50" p="3">
          <Flex align="center" gap="2">
            <CalendarIcon width="16" height="16" className="text-gray-700" />
            <Text weight="bold" size="2" className="text-gray-900">Daftar Permohonan</Text>
          </Flex>
          <Text size="1" color="gray">{filteredPengajuanIzin.length} data</Text>
        </Flex>

        <Table.Root variant="surface" size="1">
          <Table.Header>
            <Table.Row className="bg-gray-50/80">
              <Table.ColumnHeaderCell className="p-3">Peserta</Table.ColumnHeaderCell>
              <Table.ColumnHeaderCell className="p-3">Jenis</Table.ColumnHeaderCell>
              <Table.ColumnHeaderCell className="p-3">Tanggal</Table.ColumnHeaderCell>
              <Table.ColumnHeaderCell className="p-3">Alasan</Table.ColumnHeaderCell>
              <Table.ColumnHeaderCell className="p-3">Status</Table.ColumnHeaderCell>
              <Table.ColumnHeaderCell className="p-3" align="center">Detail</Table.ColumnHeaderCell>
            </Table.Row>
          </Table.Header>
          <Table.Body>
            {paginatedData.map((item) => (
              <Table.Row key={item.id} className="hover:bg-blue-50/30 transition-colors">
                <Table.Cell className="p-3">
                  <div className="flex items-center">
                    <Avatar src={item.pesertaMagang?.avatar} alt={item.pesertaMagang?.nama || ""} name={item.pesertaMagang?.nama || ""} size="sm" showBorder className="border-gray-200 shadow-sm" />
                    <div className="ml-3">
                      <div className="text-xs font-semibold text-gray-900">{item.pesertaMagang?.nama}</div>
                      <div className="text-[10px] text-gray-500">@{item.pesertaMagang?.username}</div>
                    </div>
                  </div>
                </Table.Cell>
                <Table.Cell className="p-3 align-middle"><TypeBadge tipe={item.tipe} /></Table.Cell>
                <Table.Cell className="p-3 align-middle">
                  <Text size="1">{new Date(item.tanggalMulai).toLocaleDateString("id-ID")} {item.tanggalMulai !== item.tanggalSelesai && `- ${new Date(item.tanggalSelesai).toLocaleDateString("id-ID")}`}</Text>
                </Table.Cell>
                <Table.Cell className="p-3 align-middle"><Text size="1" color="gray" className="max-w-[150px] truncate block">{item.alasan}</Text></Table.Cell>
                <Table.Cell className="p-3 align-middle"><StatusBadge status={item.status} /></Table.Cell>
                <Table.Cell className="p-3 align-middle" align="center">
                  
                  {/* DETAIL & ADMIN DIALOG */}
                  <Dialog.Root>
                    <Dialog.Trigger>
                      <IconButton size="1" variant="outline" color="blue" title="Lihat & Kelola" className="cursor-pointer"><EyeOpenIcon width="14" height="14" /></IconButton>
                    </Dialog.Trigger>
                    
                    <Dialog.Content className="p-0 overflow-hidden max-w-xl">
                      <div className="p-5 border-b border-gray-100 flex justify-between items-center bg-gray-50/50">
                        <div>
                           <Dialog.Title className="text-lg font-bold m-0">Review Permohonan</Dialog.Title>
                           <Text size="1" color="gray">ID: {item.id.slice(0,8)}</Text>
                        </div>
                        <StatusBadge status={item.status} />
                      </div>
                      
                      <div className="p-6">
                        {/* 1. Info Peserta */}
                        <Flex gap="3" align="center" className="mb-6 p-3 bg-blue-50/50 rounded-lg border border-blue-100">
                           <Avatar src={item.pesertaMagang?.avatar} alt={item.pesertaMagang?.nama || ""} name={item.pesertaMagang?.nama || ""} size="md" />
                           <Box>
                              <Text weight="bold" size="2" className="block">{item.pesertaMagang?.nama}</Text>
                              <Text size="1" color="gray">{item.pesertaMagang?.divisi || "Divisi Magang"}</Text>
                           </Box>
                        </Flex>

                        {/* 2. Detail Izin */}
                        <Grid columns="2" gap="4" mb="4">
                           <Box>
                              <Text size="1" color="gray" className="uppercase text-[10px] font-bold">Jenis Izin</Text>
                              <div className="mt-1"><TypeBadge tipe={item.tipe} /></div>
                           </Box>
                           <Box>
                              <Text size="1" color="gray" className="uppercase text-[10px] font-bold">Durasi</Text>
                              <Text size="2" weight="medium" className="block mt-1">
                                {new Date(item.tanggalMulai).toLocaleDateString("id-ID", { day: 'numeric', month: 'short' })} - {new Date(item.tanggalSelesai).toLocaleDateString("id-ID", { day: 'numeric', month: 'short', year: 'numeric' })}
                              </Text>
                           </Box>
                        </Grid>

                        <Box mb="4">
                           <Text size="1" color="gray" className="uppercase text-[10px] font-bold mb-1">Alasan Pengajuan</Text>
                           <div className="bg-gray-50 p-3 rounded-md border border-gray-200 text-sm text-gray-700 leading-relaxed">
                              {item.alasan}
                           </div>
                        </Box>

                        {item.dokumenPendukung && (
                           <Box mb="6">
                              <Text size="1" color="gray" className="uppercase text-[10px] font-bold mb-1">Dokumen Pendukung</Text>
                              <Button variant="outline" size="2" onClick={() => window.open(item.dokumenPendukung, '_blank')} className="cursor-pointer w-full justify-start">
                                 <FileTextIcon className="mr-2"/> Lihat Lampiran Dokumen <ExternalLinkIcon className="ml-auto opacity-50"/>
                              </Button>
                           </Box>
                        )}

                        <Separator size="4" my="4" />

                        {/* 3. Admin Actions Panel */}
                        <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
                           <Text size="2" weight="bold" className="flex items-center gap-2 mb-3 text-gray-700">
                              <PersonIcon /> Tindakan Admin
                           </Text>

                           {item.status === "PENDING" ? (
                              <Grid columns="2" gap="3">
                                 <Button color="red" variant="soft" onClick={() => handleReject(item.id)} className="cursor-pointer">
                                    <CrossCircledIcon /> Tolak Izin
                                 </Button>
                                 <Button color="green" variant="solid" onClick={() => handleApprove(item.id)} className="cursor-pointer">
                                    <CheckCircledIcon /> Setujui Izin
                                 </Button>
                              </Grid>
                           ) : (
                              <div className="text-center py-2 mb-3">
                                 <Text size="1" color="gray">Permohonan ini telah <b>{item.status === 'DISETUJUI' ? 'disetujui' : 'ditolak'}</b>.</Text>
                              </div>
                           )}

                           <div className="mt-4 pt-3 border-t border-gray-200">
                              <Button variant="ghost" color="red" size="1" onClick={() => setDeleteId(item.id)} className="w-full justify-center hover:bg-red-50 cursor-pointer">
                                 <TrashIcon className="mr-1"/> Hapus Data Permohonan
                              </Button>
                           </div>
                        </div>

                      </div>
                      <div className="p-3 bg-gray-100 flex justify-end">
                         <Dialog.Close><Button variant="soft" color="gray">Tutup</Button></Dialog.Close>
                      </div>
                    </Dialog.Content>
                  </Dialog.Root>

                </Table.Cell>
              </Table.Row>
            ))}
          </Table.Body>
        </Table.Root>

        {filteredPengajuanIzin.length === 0 && <Box className="text-center py-10"><Text size="2" color="gray">Tidak ada data</Text></Box>}
        
        {/* Pagination */}
        {filteredPengajuanIzin.length > 0 && (
          <Flex justify="between" align="center" p="3" className="border-t border-gray-100 bg-gray-50/50">
            <Text size="1" color="gray">Halaman {currentPage} dari {totalPages}</Text>
            <Flex gap="1">
              <Button variant="soft" color="gray" size="1" disabled={currentPage === 1} onClick={() => setCurrentPage(1)}><DoubleArrowLeftIcon width="12" height="12" /></Button>
              <Button variant="soft" color="gray" size="1" disabled={currentPage === 1} onClick={() => setCurrentPage(c => c - 1)}><ChevronLeftIcon width="12" height="12" /></Button>
              <div className="hidden sm:flex gap-1 mx-1">{renderPaginationButtons()}</div>
              <Button variant="soft" color="gray" size="1" disabled={currentPage === totalPages} onClick={() => setCurrentPage(c => c + 1)}><ChevronRightIcon width="12" height="12" /></Button>
              <Button variant="soft" color="gray" size="1" disabled={currentPage === totalPages} onClick={() => setCurrentPage(totalPages)}><DoubleArrowRightIcon width="12" height="12" /></Button>
            </Flex>
          </Flex>
        )}
      </Card>

      {/* Delete Alert */}
      <AlertDialog.Root open={!!deleteId} onOpenChange={(open) => !open && setDeleteId(null)}>
        <AlertDialog.Content maxWidth="450px">
          <AlertDialog.Title>Hapus Permohonan</AlertDialog.Title>
          <AlertDialog.Description size="2">
            Apakah Anda yakin ingin menghapus data permohonan ini secara permanen?
          </AlertDialog.Description>
          <Flex gap="3" mt="4" justify="end">
            <AlertDialog.Cancel><Button variant="soft" color="gray" className="cursor-pointer">Batal</Button></AlertDialog.Cancel>
            <AlertDialog.Action><Button variant="solid" color="red" onClick={handleDelete} className="cursor-pointer">Hapus</Button></AlertDialog.Action>
          </Flex>
        </AlertDialog.Content>
      </AlertDialog.Root>
    </div>
  );
}