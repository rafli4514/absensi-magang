import { useState, useEffect, useMemo } from "react";
import { 
  Box, 
  Grid, 
  Text, 
  Flex, 
  Card, 
  Badge, 
  IconButton, 
  Table, 
  TextField, 
  Dialog, 
  Button, 
  Tooltip,
  Select,
  AlertDialog
} from "@radix-ui/themes";
import { 
  CrossCircledIcon, 
  ClockIcon, 
  UpdateIcon, 
  MagnifyingGlassIcon, 
  MixerHorizontalIcon, 
  EyeOpenIcon, 
  CheckIcon, 
  FileTextIcon, 
  ExternalLinkIcon, 
  TrashIcon, 
  ListBulletIcon
} from "@radix-ui/react-icons";

// Services
import dashboardService from "../services/dashboardService";
import absensiService from "../services/absensiService";
import pengajuanIzinService from "../services/pengajuanIzinService";

// Types & Utils
import type { Absensi, PengajuanIzin, UnifiedAttendanceLog } from "../types";
import Avatar from "../components/Avatar";

export default function KehadiranPage() {
  // ================= STATE =================
  const [rawDataAbsensi, setRawDataAbsensi] = useState<Absensi[]>([]);
  const [rawDataIzin, setRawDataIzin] = useState<PengajuanIzin[]>([]);
  const [loading, setLoading] = useState(true);
  
  // Dashboard Stats
  const [stats, setStats] = useState({ hadir: 0, izin: 0, sakit: 0, pending: 0, alpha: 0 });

  // Filters & Search
  const [filterStatus, setFilterStatus] = useState<string>("ALL");
  const [searchQuery, setSearchQuery] = useState("");

  // Pagination State
  const [currentPage, setCurrentPage] = useState(1);
  const [itemsPerPage, setItemsPerPage] = useState(10); 

  // Modal Detail State
  const [selectedLog, setSelectedLog] = useState<UnifiedAttendanceLog | null>(null);
  const [isDetailOpen, setIsDetailOpen] = useState(false);
  const [pendingStatus, setPendingStatus] = useState<string | null>(null);

  // Delete Confirmation State
  const [deleteLogId, setDeleteLogId] = useState<string | null>(null);
  const [deleteLogSource, setDeleteLogSource] = useState<'ABSENSI' | 'IZIN' | null>(null);

  // ================= FETCH DATA =================
  const fetchData = async () => {
    setLoading(true);
    try {
      const statsRes = await dashboardService.getStats();
      if (statsRes.success && statsRes.data) {
        const d = statsRes.data.attendance;
        setStats({
          hadir: d?.present ?? 0,
          izin: d?.permission ?? 0,
          sakit: d?.sick ?? 0,
          pending: d?.pending ?? 0,
          alpha: d?.alpha ?? 0
        });
      }

      const [absensiRes, izinRes] = await Promise.all([
        absensiService.getAbsensi({ limit: 500 }), 
        pengajuanIzinService.getAll({ limit: 500 })
      ]);

      if (absensiRes.success) setRawDataAbsensi(absensiRes.data || []);
      if (izinRes.success) setRawDataIzin(izinRes.data || []);

    } catch (error) {
      console.error("Error fetching data", error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { fetchData(); }, []);

  // ================= DATA TRANSFORMATION & SORTING =================
  const unifiedLogs: UnifiedAttendanceLog[] = useMemo(() => {
    const logs: UnifiedAttendanceLog[] = [];

    // Process Absensi
    rawDataAbsensi.forEach(item => {
      logs.push({
        id: item.id,
        sourceType: 'ABSENSI',
        peserta: item.pesertaMagang,
        timestamp: item.timestamp,
        statusDisplay: item.status === 'VALID' ? 'HADIR' : item.status === 'TERLAMBAT' ? 'TERLAMBAT' : 'INVALID',
        statusColor: item.status === 'VALID' ? 'green' : item.status === 'TERLAMBAT' ? 'orange' : 'red',
        tipe: item.tipe,
        detailTimeOrDuration: new Date(item.timestamp).toLocaleTimeString('id-ID', {hour: '2-digit', minute:'2-digit'}),
        lokasiOrAlasan: item.lokasi?.alamat || 'Lokasi tidak terdeteksi',
        buktiUrl: item.selfieUrl,
        originalData: item
      });
    });

    // Process Izin
    rawDataIzin.forEach(item => {
      let displayStatus: UnifiedAttendanceLog['statusDisplay'] = 'PENDING';
      let color: UnifiedAttendanceLog['statusColor'] = 'yellow';

      if (item.status === 'DISETUJUI') {
        displayStatus = item.tipe === 'SAKIT' ? 'SAKIT' : 'IZIN';
        color = item.tipe === 'SAKIT' ? 'red' : 'blue';
      } else if (item.status === 'DITOLAK') {
        displayStatus = 'REJECTED';
        color = 'gray';
      }

      logs.push({
        id: item.id,
        sourceType: 'IZIN',
        peserta: item.pesertaMagang,
        timestamp: item.diajukanPada,
        statusDisplay: displayStatus,
        statusColor: color,
        tipe: item.tipe,
        detailTimeOrDuration: `${new Date(item.tanggalMulai).toLocaleDateString('id-ID', {day: 'numeric', month:'short'})} - ${new Date(item.tanggalSelesai).toLocaleDateString('id-ID', {day: 'numeric', month:'short'})}`,
        lokasiOrAlasan: item.alasan,
        buktiUrl: item.dokumenPendukung,
        originalData: item
      });
    });

    // --- SORTING LOGIC ---
    return logs.sort((a, b) => {
      // 1. Prioritas Utama: Status 'PENDING' (Alert) harus paling atas
      const isAPending = a.statusDisplay === 'PENDING';
      const isBPending = b.statusDisplay === 'PENDING';

      if (isAPending && !isBPending) return -1; // a naik ke atas
      if (!isAPending && isBPending) return 1;  // b naik ke atas

      // 2. Prioritas Kedua: Waktu terbaru (Latest) diletakkan di atas
      // Jika status sama-sama pending atau sama-sama bukan pending, urutkan berdasarkan waktu
      return new Date(b.timestamp).getTime() - new Date(a.timestamp).getTime();
    });
  }, [rawDataAbsensi, rawDataIzin]);

  // ================= FILTERING =================
  const filteredLogs = unifiedLogs.filter(log => {
    if (filterStatus === 'PENDING' && log.statusDisplay !== 'PENDING') return false;
    if (filterStatus === 'HADIR' && !['HADIR', 'TERLAMBAT'].includes(log.statusDisplay)) return false;
    if (filterStatus === 'IZIN_SAKIT' && !['IZIN', 'SAKIT'].includes(log.statusDisplay)) return false;
    
    const searchLower = searchQuery.toLowerCase();
    return (log.peserta?.nama || "").toLowerCase().includes(searchLower) || 
           log.tipe.toLowerCase().includes(searchLower);
  });

  useEffect(() => {
    setCurrentPage(1);
  }, [filterStatus, searchQuery, itemsPerPage]);

  // ================= PAGINATION =================
  const totalItems = filteredLogs.length;
  const totalPages = Math.ceil(totalItems / itemsPerPage);
  
  const paginatedData = filteredLogs.slice(
    (currentPage - 1) * itemsPerPage,
    currentPage * itemsPerPage
  );

  const renderPaginationButtons = () => {
    const buttons = [];
    const maxVisiblePages = 5;
    let startPage = Math.max(1, currentPage - Math.floor(maxVisiblePages / 2));
    const endPage = Math.min(totalPages, startPage + maxVisiblePages - 1);

    if (endPage - startPage + 1 < maxVisiblePages) {
      startPage = Math.max(1, endPage - maxVisiblePages + 1);
    }

    for (let i = startPage; i <= endPage; i++) {
      buttons.push(
        <Button 
          key={i} 
          size="1" 
          variant={currentPage === i ? "solid" : "soft"} 
          color={currentPage === i ? "indigo" : "gray"} 
          onClick={() => setCurrentPage(i)} 
          className="w-8 h-8 p-0 cursor-pointer"
        >
          {i}
        </Button>
      );
    }
    return buttons;
  };

  // ================= ACTIONS =================
  const handleOpenDetail = (log: UnifiedAttendanceLog) => {
    setSelectedLog(log);
    setPendingStatus(null);
    setIsDetailOpen(true);
  };

  const handleUpdateStatus = async (log: UnifiedAttendanceLog, status: string) => {
    setLoading(true);
    try {
      if (log.sourceType === 'ABSENSI') {
        await absensiService.updateAbsensi(log.id, { status: status as Absensi["status"] });
      } else {
        if (status === 'DISETUJUI') await pengajuanIzinService.approve(log.id, "Diubah oleh Admin");
        else if (status === 'DITOLAK') await pengajuanIzinService.reject(log.id, "Diubah oleh Admin");
        else await pengajuanIzinService.update(log.id, { status: status as "PENDING" });
      }
      setIsDetailOpen(false);
      await fetchData();
    } catch (e) {
      console.error("Update error:", e);
      alert("Gagal memperbarui status.");
    } finally {
      setLoading(false);
    }
  };

  const executeDelete = async () => {
    if (!deleteLogId || !deleteLogSource) return;
    setLoading(true);
    try {
      if (deleteLogSource === 'ABSENSI') {
        await absensiService.deleteAbsensi(deleteLogId);
      } else {
        await pengajuanIzinService.delete(deleteLogId);
      }
      setDeleteLogId(null);
      setIsDetailOpen(false);
      await fetchData();
    } catch (e) {
      console.error("Delete error:", e);
      alert("Gagal menghapus data.");
    } finally {
      setLoading(false);
    }
  };

  // ================= RENDER =================
  return (
    <div className="space-y-6 pb-20 animate-in fade-in duration-500">
      
      {/* 1. DASHBOARD HEADER & SEARCH */}
      <Flex justify="between" align="center" wrap="wrap" gap="4">
        <Box>
          <Text size="5" weight="bold" className="text-gray-900 tracking-tight">Attendance Control</Text>
          <Text size="2" color="gray">Pusat kendali kehadiran harian dan persetujuan izin.</Text>
        </Box>
        <Box className="w-full md:w-auto">
           <TextField.Root placeholder="Cari nama peserta..." value={searchQuery} onChange={e => setSearchQuery(e.target.value)} size="2">
              <TextField.Slot><MagnifyingGlassIcon/></TextField.Slot>
           </TextField.Root>
        </Box>
      </Flex>

      {/* 2. UNIFIED LOG TABLE */}
      <Card className="p-0 overflow-hidden shadow-sm border border-gray-200">
        
        {/* TABLE TOOLBAR */}
        <div className="p-4 border-b border-gray-200 bg-gray-50/50 flex flex-col md:flex-row justify-between items-center gap-4">
          <Flex align="center" gap="4">
             <div className="flex items-center gap-2">
                <MixerHorizontalIcon className="text-gray-500 w-5 h-5" />
                <Text size="3" weight="bold" className="text-gray-800">Log Aktivitas Terbaru</Text>
             </div>
             
             <div className="h-6 w-px bg-gray-300 hidden md:block"></div>

             <div className="flex items-center gap-2">
                <Tooltip content="Refresh Data">
                  <IconButton 
                    size="1" 
                    variant="soft" 
                    color="gray" 
                    onClick={fetchData} 
                    loading={loading}
                    className="cursor-pointer"
                  >
                    <UpdateIcon className={loading ? "animate-spin" : ""} width="14" height="14"/>
                  </IconButton>
                </Tooltip>
                
                <Badge color="gray" variant="surface" radius="full" className="ml-1">
                  {totalItems} Data
                </Badge>
             </div>
          </Flex>

          <Flex gap="3" align="center" wrap="wrap" className="w-full md:w-auto justify-end">
             <Select.Root value={filterStatus} onValueChange={setFilterStatus}>
                <Select.Trigger variant="surface" color="indigo" radius="medium" placeholder="Filter Status" className="min-w-[140px]" />
                <Select.Content position="popper">
                   <Select.Item value="ALL">Semua Status</Select.Item>
                   <Select.Item value="PENDING">⚠️ Perlu Review ({stats.pending})</Select.Item>
                   <Select.Item value="HADIR">✅ Hadir ({stats.hadir})</Select.Item>
                   <Select.Item value="IZIN_SAKIT">📄 Izin / Sakit ({stats.izin + stats.sakit})</Select.Item>
                </Select.Content>
             </Select.Root>

             <Flex align="center" gap="2" className="bg-white rounded-md border border-gray-200 px-2 py-1">
               <Text size="1" color="gray" className="hidden sm:inline font-medium">Rows:</Text>
               <Select.Root value={itemsPerPage.toString()} onValueChange={(val) => setItemsPerPage(Number(val))}>
                  <Select.Trigger variant="ghost" color="gray" radius="medium" className="h-6 min-w-[50px] p-0 text-xs font-bold">
                    <Flex gap="1" align="center"><ListBulletIcon />{itemsPerPage}</Flex>
                  </Select.Trigger>
                  <Select.Content position="popper">
                     <Select.Item value="10">10</Select.Item>
                     <Select.Item value="20">20</Select.Item>
                     <Select.Item value="50">50</Select.Item>
                     <Select.Item value="100">100</Select.Item>
                  </Select.Content>
               </Select.Root>
             </Flex>
          </Flex>
        </div>

        {/* TABLE CONTENT */}
        <Table.Root variant="surface">
          <Table.Header>
            <Table.Row className="bg-white">
              <Table.ColumnHeaderCell>Peserta</Table.ColumnHeaderCell>
              <Table.ColumnHeaderCell>Tipe & Waktu</Table.ColumnHeaderCell>
              <Table.ColumnHeaderCell>Keterangan</Table.ColumnHeaderCell>
              <Table.ColumnHeaderCell>Status</Table.ColumnHeaderCell>
              <Table.ColumnHeaderCell align="center">Aksi</Table.ColumnHeaderCell>
            </Table.Row>
          </Table.Header>

          <Table.Body>
            {loading && rawDataAbsensi.length === 0 ? (
               <Table.Row>
                 <Table.Cell colSpan={5} className="py-12 text-center">
                    <Text color="gray">Memuat data...</Text>
                 </Table.Cell>
               </Table.Row>
            ) : paginatedData.length === 0 ? (
              <Table.Row>
                <Table.Cell colSpan={5} className="py-12 text-center">
                  <Text color="gray">Tidak ada data yang sesuai filter.</Text>
                </Table.Cell>
              </Table.Row>
            ) : (
              paginatedData.map((log) => (
                <Table.Row key={`${log.sourceType}-${log.id}`} className="hover:bg-blue-50/30 transition-colors group">
                  <Table.Cell>
                    <Flex gap="3" align="center">
                      <Avatar 
                        src={log.peserta?.avatar} 
                        name={log.peserta?.nama || "?"} 
                        size="sm" 
                        alt={log.peserta?.nama || "Peserta"}
                      />
                      <Box>
                        <Text weight="bold" size="2" className="block">{log.peserta?.nama}</Text>
                        <Text size="1" color="gray">{log.peserta?.divisi}</Text>
                      </Box>
                    </Flex>
                  </Table.Cell>
                  
                  <Table.Cell>
                    <Flex direction="column">
                      <Text size="2" weight="medium" className="flex items-center gap-1">
                        {log.sourceType === 'IZIN' ? <FileTextIcon className="text-blue-500"/> : <ClockIcon className="text-gray-500"/>}
                        {log.tipe}
                      </Text>
                      <Text size="1" color="gray">{log.detailTimeOrDuration}</Text>
                    </Flex>
                  </Table.Cell>

                  <Table.Cell>
                    <Text size="2" className="truncate max-w-[200px] block" title={log.lokasiOrAlasan}>
                      {log.lokasiOrAlasan}
                    </Text>
                  </Table.Cell>

                  <Table.Cell>
                    <Badge color={log.statusColor} variant={log.statusDisplay === 'PENDING' ? 'solid' : 'soft'}>
                      {log.statusDisplay}
                    </Badge>
                  </Table.Cell>

                  <Table.Cell align="center">
                    <Flex gap="2" justify="center" align="center">
                      {log.statusDisplay === 'PENDING' ? (
                        <>
                          <Tooltip content="Approve">
                            <IconButton size="1" color="green" variant="soft" onClick={() => handleUpdateStatus(log, log.sourceType === 'ABSENSI' ? 'VALID' : 'DISETUJUI')}>
                              <CheckIcon />
                            </IconButton>
                          </Tooltip>
                          <Tooltip content="Lihat Detail">
                            <IconButton size="1" color="gray" variant="soft" onClick={() => handleOpenDetail(log)}>
                              <EyeOpenIcon />
                            </IconButton>
                          </Tooltip>
                        </>
                      ) : (
                        <Tooltip content="Lihat Detail & Pengaturan">
                          <IconButton size="1" variant="ghost" color="gray" onClick={() => handleOpenDetail(log)}>
                            <EyeOpenIcon />
                          </IconButton>
                        </Tooltip>
                      )}
                    </Flex>
                  </Table.Cell>
                </Table.Row>
              ))
            )}
          </Table.Body>
        </Table.Root>

        {/* PAGINATION FOOTER */}
        {totalItems > 0 && (
          <Flex justify="between" align="center" p="3" className="border-t border-gray-100 bg-white">
            <Text size="1" color="gray">
               Menampilkan {((currentPage - 1) * itemsPerPage) + 1} - {Math.min(currentPage * itemsPerPage, totalItems)} dari {totalItems} data
            </Text>
            <Flex gap="1">
              <Button variant="soft" color="gray" size="1" disabled={currentPage === 1} onClick={() => setCurrentPage(1)} className="cursor-pointer">&lt;&lt;</Button>
              <Button variant="soft" color="gray" size="1" disabled={currentPage === 1} onClick={() => setCurrentPage(c => c - 1)} className="cursor-pointer">&lt;</Button>
              <div className="hidden sm:flex gap-1 mx-1">{renderPaginationButtons()}</div>
              <Button variant="soft" color="gray" size="1" disabled={currentPage === totalPages} onClick={() => setCurrentPage(c => c + 1)} className="cursor-pointer">&gt;</Button>
              <Button variant="soft" color="gray" size="1" disabled={currentPage === totalPages} onClick={() => setCurrentPage(totalPages)} className="cursor-pointer">&gt;&gt;</Button>
            </Flex>
          </Flex>
        )}
      </Card>

      {/* 4. REDESIGNED DETAIL MODAL (COMPACT & SOLID) */}
      <Dialog.Root open={isDetailOpen} onOpenChange={setIsDetailOpen}>
        <Dialog.Content maxWidth="500px" className="p-0 overflow-hidden rounded-xl shadow-xl">
          {selectedLog && (
            <Flex direction="column" className="max-h-[85vh]">
              
              {/* --- HEADER --- */}
              <Box className="bg-gray-50 border-b border-gray-200 p-5">
                <Flex justify="between" align="center">
                  <Flex gap="3" align="center">
                    <Avatar 
                      src={selectedLog.peserta?.avatar} 
                      name={selectedLog.peserta?.nama || "?"} 
                      size="md" 
                      alt={selectedLog.peserta?.nama || "Peserta"}
                      className="ring-2 ring-white shadow-sm"
                    />
                    <Box>
                      <Text size="3" weight="bold" className="text-gray-900 leading-tight block">
                        {selectedLog.peserta?.nama}
                      </Text>
                      <Text size="1" className="text-gray-500 font-medium">
                        {selectedLog.peserta?.divisi}
                      </Text>
                    </Box>
                  </Flex>
                  <Badge size="2" variant="surface" color={selectedLog.statusColor} className="font-bold px-2">
                    {selectedLog.statusDisplay}
                  </Badge>
                </Flex>
              </Box>

              {/* --- BODY --- */}
              <Box className="p-5 space-y-5 overflow-y-auto">
                <Grid columns="2" gapX="4" gapY="4">
                   <Box>
                      <Text size="1" className="text-gray-500 font-semibold uppercase tracking-wider block mb-1">
                        Tipe Input
                      </Text>
                      <Text size="2" weight="bold" className="text-gray-900 flex items-center gap-2">
                        {selectedLog.tipe}
                      </Text>
                   </Box>
                   <Box>
                      <Text size="1" className="text-gray-500 font-semibold uppercase tracking-wider block mb-1">
                        Waktu / Durasi
                      </Text>
                      <Text size="2" weight="medium" className="text-gray-900 font-mono">
                        {selectedLog.detailTimeOrDuration}
                      </Text>
                   </Box>
                   <Box className="col-span-2">
                      <Text size="1" className="text-gray-500 font-semibold uppercase tracking-wider block mb-1">
                        {selectedLog.sourceType === 'IZIN' ? 'Alasan Pengajuan' : 'Lokasi Absensi'}
                      </Text>
                      <div className="bg-gray-50 p-2.5 rounded-lg border border-gray-100 text-sm text-gray-800 leading-relaxed">
                        {selectedLog.lokasiOrAlasan || "-"}
                      </div>
                   </Box>
                </Grid>

                <Box>
                  <Text size="1" className="text-gray-500 font-semibold uppercase tracking-wider block mb-1">
                    Lampiran Bukti
                  </Text>
                  {selectedLog.buktiUrl ? (
                    selectedLog.sourceType === 'ABSENSI' ? (
                      <div className="relative rounded-lg overflow-hidden border border-gray-200 shadow-sm aspect-video bg-gray-100">
                        <img src={selectedLog.buktiUrl} alt="Bukti" className="w-full h-full object-cover" />
                      </div>
                    ) : (
                      <Button variant="outline" className="w-full justify-start h-10 border-gray-300 text-gray-700" onClick={() => window.open(selectedLog.buktiUrl, '_blank')}>
                        <FileTextIcon className="mr-2 text-blue-500"/> Buka Dokumen Pendukung <ExternalLinkIcon className="ml-auto opacity-50"/>
                      </Button>
                    )
                  ) : (
                    <Flex align="center" gap="2" className="py-2 px-3 bg-gray-50 rounded-md border border-dashed border-gray-300 text-gray-400">
                      <CrossCircledIcon />
                      <Text size="2" className="italic">Tidak ada lampiran bukti</Text>
                    </Flex>
                  )}
                </Box>

                {/* MODIFIED: UPDATE STATUS DI DALAM BODY */}
                {(selectedLog.sourceType === "ABSENSI" || (selectedLog.sourceType === "IZIN" && selectedLog.statusDisplay !== "PENDING")) && (
                   <Box className="pt-2 border-t border-dashed border-gray-200">
                      <Text size="1" className="text-gray-500 font-semibold uppercase tracking-wider block mb-2">
                        Update Status (Admin)
                      </Text>
                      <Select.Root 
                        value={pendingStatus ?? selectedLog.originalData.status} 
                        onValueChange={setPendingStatus}
                      >
                        <Select.Trigger className="w-full h-9 bg-white border-gray-300 shadow-sm" placeholder="Ubah Status..." />
                        <Select.Content position="popper">
                          {selectedLog.sourceType === 'ABSENSI' ? (
                            <>
                              <Select.Item value="VALID">✅ Valid (Hadir)</Select.Item>
                              <Select.Item value="TERLAMBAT">⚠️ Terlambat</Select.Item>
                              <Select.Item value="INVALID">❌ Invalid</Select.Item>
                            </>
                          ) : (
                            <>
                              <Select.Item value="DISETUJUI">✅ Disetujui</Select.Item>
                              <Select.Item value="DITOLAK">❌ Ditolak</Select.Item>
                              <Select.Item value="PENDING">⏳ Pending</Select.Item>
                            </>
                          )}
                        </Select.Content>
                      </Select.Root>
                   </Box>
                )}
              </Box>

              {/* --- FOOTER: COMPACT ACTIONS --- */}
              <Flex justify="between" align="center" p="4" className="bg-gray-50 border-t border-gray-200">
                 {/* Left: Delete */}
                 <Tooltip content="Hapus Log">
                    <IconButton 
                      variant="ghost" 
                      color="red" 
                      className="cursor-pointer hover:bg-red-100 text-red-600"
                      onClick={() => {
                        setDeleteLogId(selectedLog.id);
                        setDeleteLogSource(selectedLog.sourceType);
                      }}
                    >
                      <TrashIcon width="18" height="18"/>
                    </IconButton>
                 </Tooltip>

                 {/* Right: Primary Actions */}
                 <Flex gap="3">
                    <Dialog.Close>
                      <Button variant="outline" color="gray" className="cursor-pointer text-gray-700 bg-white border-gray-300">
                        {selectedLog.statusDisplay === 'PENDING' ? 'Batal' : 'Tutup'}
                      </Button>
                    </Dialog.Close>
                    
                    {selectedLog.statusDisplay === 'PENDING' ? (
                       <>
                         <Button color="red" variant="soft" className="cursor-pointer" onClick={() => handleUpdateStatus(selectedLog, "DITOLAK")}>
                           Tolak
                         </Button>
                         <Button color="green" className="cursor-pointer text-white" onClick={() => handleUpdateStatus(selectedLog, "DISETUJUI")}>
                           Setujui
                         </Button>
                       </>
                    ) : (
                       <Button 
                         className="cursor-pointer bg-blue-600 text-white hover:bg-blue-700" 
                         disabled={!pendingStatus || pendingStatus === selectedLog.originalData.status}
                         onClick={() => handleUpdateStatus(selectedLog, pendingStatus!)}
                       >
                         Simpan Perubahan
                       </Button>
                    )}
                 </Flex>
              </Flex>

            </Flex>
          )}
        </Dialog.Content>
      </Dialog.Root>

      {/* Delete Confirmation Alert */}
      <AlertDialog.Root open={!!deleteLogId} onOpenChange={(open) => !open && setDeleteLogId(null)}>
        <AlertDialog.Content maxWidth="450px">
          <AlertDialog.Title>Konfirmasi Hapus</AlertDialog.Title>
          <AlertDialog.Description size="2">
            Apakah Anda yakin ingin menghapus data log ini? Tindakan ini tidak dapat dibatalkan.
          </AlertDialog.Description>
          <Flex gap="3" mt="4" justify="end">
            <AlertDialog.Cancel>
              <Button variant="soft" color="gray" className="cursor-pointer">Batal</Button>
            </AlertDialog.Cancel>
            <AlertDialog.Action>
              <Button variant="solid" color="red" onClick={executeDelete} className="cursor-pointer">Ya, Hapus</Button>
            </AlertDialog.Action>
          </Flex>
        </AlertDialog.Content>
      </AlertDialog.Root>
    </div>
  );
}