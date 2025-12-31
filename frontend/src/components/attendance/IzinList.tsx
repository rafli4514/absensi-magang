import { useState, useEffect } from "react";
import type { Absensi, PesertaMagang } from "../../types";
import { formatDateTime } from "../../lib/utils";
import {
  AspectRatio,
  Box,
  Button,
  Card,
  Dialog,
  Flex,
  IconButton,
  Select,
  Table,
  Text,
  TextField,
  DropdownMenu,
  AlertDialog,
  Badge,
  Separator,
  Grid
} from "@radix-ui/themes";
import {
  CheckCircledIcon,
  CircleBackslashIcon,
  ClockIcon,
  CrossCircledIcon,
  DownloadIcon,
  EyeOpenIcon,
  InfoCircledIcon,
  MixerHorizontalIcon,
  ChevronLeftIcon,
  ChevronRightIcon,
  DoubleArrowLeftIcon,
  DoubleArrowRightIcon,
  FileTextIcon,
  FileIcon,
  TrashIcon,
  PersonIcon,
  SewingPinFilledIcon
} from "@radix-ui/react-icons";

import absensiService from "../../services/absensiService";
import Avatar from "../Avatar";

import LogoPLN from "../../assets/64eb562e223ee070362018.png";
import * as XLSX from "xlsx";
import jsPDF from "jspdf";
import autoTable from "jspdf-autotable";

const StatusIcon = ({ status }: { status: Absensi["status"] }) => {
  switch (status) {
    case "VALID": return <CheckCircledIcon color="green" />;
    case "TERLAMBAT": return <InfoCircledIcon color="orange" />;
    case "INVALID": return <CrossCircledIcon color="red" />;
    default: return <CircleBackslashIcon color="gray" />;
  }
};

const StatusBadge = ({ status }: { status: Absensi["status"] }) => {
  const statusConfig: Record<string, { color: string; label: string }> = {
    VALID: { color: "bg-green-100 text-green-800", label: "Valid" },
    TERLAMBAT: { color: "bg-yellow-100 text-yellow-800", label: "Terlambat" },
    INVALID: { color: "bg-red-100 text-red-800", label: "Tidak Valid" },
  };
  const config = statusConfig[status] || { color: "bg-gray-100 text-gray-800", label: status };
  return <span className={`inline-flex px-2 py-0.5 text-[10px] font-semibold rounded-full ${config.color}`}>{config.label}</span>;
};

const TypeBadge = ({ tipe }: { tipe: Absensi["tipe"] }) => {
  const typeConfig: Record<string, { color: string; label: string }> = {
    MASUK: { color: "bg-blue-100 text-blue-800", label: "Masuk" },
    KELUAR: { color: "bg-purple-100 text-purple-800", label: "Keluar" },
    IZIN: { color: "bg-orange-100 text-orange-800", label: "Izin" },
    SAKIT: { color: "bg-red-100 text-red-800", label: "Sakit" },
    CUTI: { color: "bg-green-100 text-green-800", label: "Cuti" },
  };
  const config = typeConfig[tipe] || { color: "bg-gray-100 text-gray-800", label: tipe };
  return <span className={`inline-flex px-2 py-0.5 text-[10px] font-semibold rounded-full ${config.color}`}>{config.label}</span>;
};

export default function AbsensiList() {
  const [absensi, setAbsensi] = useState<Absensi[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // States for Filters
  const [searchTerm, setSearchTerm] = useState("");
  const [statusFilter, setStatusFilter] = useState<string>("Semua");
  const [typeFilter, setTypeFilter] = useState<string>("Semua");
  const [dateFilter, setDateFilter] = useState("");

  // Pagination
  const [currentPage, setCurrentPage] = useState(1);
  const [itemsPerPage, setItemsPerPage] = useState<string>("20");

  // Delete State
  const [deleteId, setDeleteId] = useState<string | null>(null);

  useEffect(() => {
    fetchAbsensi();
  }, []);

  const fetchAbsensi = async () => {
    try {
      setLoading(true);
      const response = await absensiService.getAbsensi({ limit: 1000 });
      if (response.success && response.data) {
        setAbsensi(response.data);
      } else {
        setError(response.message || "Failed to fetch absensi");
        setAbsensi([]);
      }
    } catch (error: unknown) {
      console.error("Fetch absensi error:", error);
      setError("Failed to fetch absensi");
      setAbsensi([]);
    } finally {
      setLoading(false);
    }
  };

  const handleUpdateStatus = async (id: string, newStatus: Absensi["status"]) => {
    try {
      const response = await absensiService.updateAbsensi(id, { status: newStatus });
      if (response.success) {
        setAbsensi(prev => prev.map(item => item.id === id ? { ...item, status: newStatus } : item));
      } else {
        alert("Gagal update status: " + response.message);
      }
    } catch (error: unknown) {
      console.error("Update status error:", error);
      alert("Terjadi kesalahan sistem");
    }
  };

  const handleDelete = async () => {
    if (!deleteId) return;
    try {
      const response = await absensiService.deleteAbsensi(deleteId);
      if (response.success) {
        setAbsensi(prev => prev.filter(item => item.id !== deleteId));
        setDeleteId(null);
      } else {
        alert("Gagal menghapus log: " + response.message);
      }
    } catch (error: unknown) {
      console.error("Delete error:", error);
      alert("Terjadi kesalahan saat menghapus log");
    }
  };

  const hasPesertaMagang = (record: Absensi): record is Absensi & { pesertaMagang: PesertaMagang } => {
    return record.pesertaMagang !== undefined && record.pesertaMagang !== null;
  };

  const filteredAbsensi = absensi.filter(hasPesertaMagang).filter((record) => {
    const matchesSearch =
      record.pesertaMagang.nama.toLowerCase().includes(searchTerm.toLowerCase()) ||
      record.pesertaMagang.username.toLowerCase().includes(searchTerm.toLowerCase());

    const matchesStatus = statusFilter === "Semua" || record.status === statusFilter;
    const matchesType = typeFilter === "Semua" || record.tipe === typeFilter;

    const recordDate = new Date(record.timestamp).toISOString().split('T')[0];
    const matchesDate = !dateFilter || recordDate === dateFilter;

    return matchesSearch && matchesStatus && matchesType && matchesDate;
  });

  useEffect(() => {
    setCurrentPage(1);
  }, [searchTerm, statusFilter, typeFilter, dateFilter, itemsPerPage]);

  const totalItems = filteredAbsensi.length;
  const pageSize = itemsPerPage === "All" ? totalItems : parseInt(itemsPerPage);
  const totalPages = Math.ceil(totalItems / pageSize);

  const paginatedData = filteredAbsensi.slice(
    (currentPage - 1) * pageSize,
    currentPage * pageSize
  );

  // --- Export Functionality ---
  const addHeaderToPDF = (doc: jsPDF, title: string) => {
    const PLN_BLUE = "#0066CC";
    const DARK_GREY = "#333333";
    const pageWidth = doc.internal.pageSize.getWidth();

    try { doc.addImage(LogoPLN, "PNG", 14, 10, 50, 20); } catch (e) { console.warn("Logo error", e); }

    doc.setTextColor(PLN_BLUE); doc.setFont("helvetica", "bold"); doc.setFontSize(16);
    doc.text("PT PLN ICON PLUS", 70, 18);
    doc.setTextColor(DARK_GREY); doc.setFont("helvetica", "normal"); doc.setFontSize(10);
    doc.text("Kantor Perwakilan Aceh Jl. Teuku Umar No. 426", 70, 24);
    
    doc.setDrawColor(PLN_BLUE); doc.setLineWidth(1); doc.line(14, 35, pageWidth - 14, 35);
    
    doc.setFont("helvetica", "bold"); doc.setFontSize(14); doc.text(title, 14, 45);
    doc.setFont("helvetica", "normal"); doc.setFontSize(10);
    doc.text(`Tanggal Cetak: ${new Date().toLocaleDateString("id-ID")}`, 14, 51);

    return 55;
  };

  const handleExport = (format: "excel" | "pdf") => {
    const fileName = `Monitoring_Absensi_${new Date().toISOString().split("T")[0]}`;
    const dataToExport = filteredAbsensi.map(item => ({
      "Nama": item.pesertaMagang?.nama, "Tipe": item.tipe,
      "Waktu": new Date(item.timestamp).toLocaleString("id-ID"),
      "Lokasi": item.lokasi?.alamat || "-", "Status": item.status, "Catatan": item.catatan || "-"
    }));

    if (format === "excel") {
      const worksheet = XLSX.utils.json_to_sheet(dataToExport);
      const workbook = XLSX.utils.book_new();
      XLSX.utils.book_append_sheet(workbook, worksheet, "Data Absensi");
      XLSX.writeFile(workbook, `${fileName}.xlsx`);
    } else if (format === "pdf") {
      const doc = new jsPDF();
      const startY = addHeaderToPDF(doc, "MONITORING ABSENSI HARIAN");
      const tableColumn = ["Nama", "Tipe", "Waktu", "Status", "Lokasi"];
      const tableRows = filteredAbsensi.map(item => [
        item.pesertaMagang?.nama, item.tipe,
        new Date(item.timestamp).toLocaleString("id-ID", {dateStyle: 'short', timeStyle: 'short'}),
        item.status, item.lokasi?.alamat ? item.lokasi.alamat.substring(0, 30) + "..." : "-"
      ]);
      autoTable(doc, {
        head: [tableColumn], body: tableRows, startY: startY, theme: 'striped',
        styles: { fontSize: 8, cellPadding: 2 }, headStyles: { fillColor: [0, 102, 204] }
      });
      doc.save(`${fileName}.pdf`);
    }
  };

  // --- Pagination Render ---
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
        <Button key={i} size="1" variant={currentPage === i ? "solid" : "soft"} color={currentPage === i ? "indigo" : "gray"} onClick={() => setCurrentPage(i)} className="w-8 h-8 p-0 cursor-pointer">{i}</Button>
      );
    }
    return buttons;
  };

  if (loading) return <div className="flex items-center justify-center h-[50vh]"><div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mx-auto"></div></div>;

  return (
    <div className="space-y-4">
      {error && <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-md text-sm">{error}</div>}

      <div className="flex justify-end mb-2">
        <DropdownMenu.Root>
          <DropdownMenu.Trigger><Button size="2" className="flex items-center cursor-pointer bg-blue-600 text-white hover:bg-blue-700"><DownloadIcon className="w-3.5 h-3.5 mr-1.5" /> Export Log</Button></DropdownMenu.Trigger>
          <DropdownMenu.Content>
            <DropdownMenu.Item onClick={() => handleExport('excel')} className="cursor-pointer"><FileIcon className="mr-2 h-4 w-4 text-green-600"/> Excel</DropdownMenu.Item>
            <DropdownMenu.Item onClick={() => handleExport('pdf')} className="cursor-pointer"><FileTextIcon className="mr-2 h-4 w-4 text-red-600"/> PDF</DropdownMenu.Item>
          </DropdownMenu.Content>
        </DropdownMenu.Root>
      </div>

      <Card className="shadow-sm">
        <Box p="3">
          <Flex direction="column" gap="3">
            <Flex gap="3" wrap="wrap" align="center" justify="between">
              <div className="flex-1 min-w-[200px]">
                <TextField.Root size="2" color="indigo" placeholder="Cari Peserta Magang…" value={searchTerm} onChange={(e) => setSearchTerm(e.target.value)} className="w-full" radius="large"><TextField.Slot><MixerHorizontalIcon height="14" width="14" /></TextField.Slot></TextField.Root>
              </div>
              <Flex gap="2" align="center" wrap="wrap" className="justify-end flex-1 sm:flex-none">
                <Select.Root size="2" defaultValue="Semua" value={statusFilter} onValueChange={setStatusFilter}>
                  <Select.Trigger color="indigo" radius="large" placeholder="Status" className="min-w-[120px]" />
                  <Select.Content color="indigo"><Select.Item value="Semua">Semua Status</Select.Item><Select.Item value="VALID">Valid</Select.Item><Select.Item value="TERLAMBAT">Terlambat</Select.Item><Select.Item value="INVALID">Tidak Valid</Select.Item></Select.Content>
                </Select.Root>
                <Select.Root size="2" defaultValue="Semua" value={typeFilter} onValueChange={setTypeFilter}>
                  <Select.Trigger color="indigo" radius="large" placeholder="Tipe" className="min-w-[100px]" />
                  <Select.Content color="indigo"><Select.Item value="Semua">Semua Tipe</Select.Item><Select.Item value="MASUK">Masuk</Select.Item><Select.Item value="KELUAR">Keluar</Select.Item><Select.Item value="IZIN">Izin</Select.Item><Select.Item value="SAKIT">Sakit</Select.Item><Select.Item value="CUTI">Cuti</Select.Item></Select.Content>
                </Select.Root>
                <div className="w-auto"><input type="date" value={dateFilter} onChange={(e) => setDateFilter(e.target.value)} className="bg-gray-50 border border-gray-200 text-xs text-gray-700 rounded-lg focus:ring-indigo-500 focus:border-indigo-500 block w-full p-1.5 h-8" /></div>
              </Flex>
            </Flex>
          </Flex>
        </Box>
      </Card>

      <Card className="shadow-sm overflow-hidden">
        <Flex direction="row" justify="between" align="center" className="border-b border-gray-100 bg-gray-50/50" p="3">
          <Flex align="center" gap="2"><ClockIcon width="16" height="16" className="text-gray-700"/><Text weight="bold" size="2" className="text-gray-900">Riwayat Kehadiran</Text></Flex>
          <Flex align="center" gap="2"><Text size="1" color="gray">Show:</Text><Select.Root value={itemsPerPage} onValueChange={setItemsPerPage} size="1"><Select.Trigger variant="ghost" color="gray" /><Select.Content position="popper"><Select.Item value="20">20</Select.Item><Select.Item value="50">50</Select.Item><Select.Item value="100">100</Select.Item><Select.Item value="All">All</Select.Item></Select.Content></Select.Root></Flex>
        </Flex>

        <Table.Root variant="surface" size="1">
          <Table.Header>
            <Table.Row className="bg-gray-50/80">
              <Table.ColumnHeaderCell className="p-3">Nama</Table.ColumnHeaderCell>
              <Table.ColumnHeaderCell className="p-3">Tipe</Table.ColumnHeaderCell>
              <Table.ColumnHeaderCell className="p-3">Waktu</Table.ColumnHeaderCell>
              <Table.ColumnHeaderCell className="p-3">Lokasi</Table.ColumnHeaderCell>
              <Table.ColumnHeaderCell className="p-3">Status</Table.ColumnHeaderCell>
              <Table.ColumnHeaderCell className="p-3" align="center">Detail</Table.ColumnHeaderCell>
            </Table.Row>
          </Table.Header>

          <Table.Body>
            {paginatedData.map((item) => (
              <Table.Row key={item.id} className="hover:bg-blue-50/30 transition-colors">
                <Table.Cell className="p-3">
                  <div className="flex items-center"><Avatar src={item.pesertaMagang?.avatar} alt={item.pesertaMagang?.nama} name={item.pesertaMagang?.nama} size="sm" showBorder={true} className="border-gray-200" /><div className="ml-3"><div className="text-xs font-semibold text-gray-900">{item.pesertaMagang?.nama}</div><div className="text-[10px] text-gray-500">@{item.pesertaMagang?.username}</div></div></div>
                </Table.Cell>
                <Table.Cell className="p-3 align-middle"><TypeBadge tipe={item.tipe} /></Table.Cell>
                <Table.Cell className="p-3 align-middle"><div className="text-xs text-gray-900">{formatDateTime(item.createdAt) || "-"}</div></Table.Cell>
                <Table.Cell className="p-3 align-middle"><div className="text-xs text-gray-900 max-w-[150px] truncate" title={item.lokasi?.alamat}>{item.lokasi?.alamat || "-"}</div></Table.Cell>
                <Table.Cell className="p-3 align-middle"><Flex align="center" gap="2"><StatusIcon status={item.status} /><StatusBadge status={item.status} /></Flex></Table.Cell>
                <Table.Cell className="p-3 align-middle" align="center">
                  
                  {/* --- DIALOG DETAIL + ADMIN CONTROLS --- */}
                  <Dialog.Root>
                    <Dialog.Trigger>
                      <IconButton size="1" color="blue" variant="outline" title="Lihat Detail & Kelola" className="cursor-pointer"><EyeOpenIcon width="14" height="14" /></IconButton>
                    </Dialog.Trigger>

                    <Dialog.Content className="p-0 overflow-hidden max-w-2xl">
                      <div className="p-6 border-b border-gray-100 flex justify-between items-center">
                        <Dialog.Title className="text-xl font-bold m-0">Detail Absensi</Dialog.Title>
                        <Badge color={item.status === "VALID" ? "green" : item.status === "TERLAMBAT" ? "orange" : "red"}>{item.status}</Badge>
                      </div>

                      <div className="p-6 grid grid-cols-1 md:grid-cols-2 gap-6">
                        {/* Foto Bukti */}
                        <div className="space-y-3">
                          <Text size="2" weight="bold" color="gray">Bukti Foto</Text>
                          <div className="relative rounded-lg overflow-hidden border border-gray-200 shadow-sm">
                            <AspectRatio ratio={4/3}>
                              <img src={item.selfieUrl || "https://placehold.co/400x300?text=No+Image"} alt="Selfie" className="w-full h-full object-cover" />
                            </AspectRatio>
                          </div>
                        </div>

                        {/* Info & Admin Controls */}
                        <div className="flex flex-col h-full justify-between gap-4">
                          <div className="space-y-4">
                            <div className="flex items-center gap-3 pb-3 border-b border-gray-100">
                              <Avatar src={item.pesertaMagang?.avatar} alt={item.pesertaMagang?.nama} name={item.pesertaMagang?.nama} size="md" />
                              <div>
                                <Text className="block text-sm font-bold text-gray-900">{item.pesertaMagang?.nama}</Text>
                                <Text className="block text-xs text-gray-500">@{item.pesertaMagang?.username}</Text>
                              </div>
                            </div>

                            <Grid columns="2" gap="2">
                               <Box><Text size="1" color="gray">Waktu Scan</Text><Text size="2" weight="medium" className="block">{formatDateTime(item.timestamp)}</Text></Box>
                               <Box><Text size="1" color="gray">Tipe Absen</Text><div className="mt-1"><TypeBadge tipe={item.tipe} /></div></Box>
                            </Grid>

                            <Box className="bg-gray-50 p-3 rounded-lg border border-gray-100">
                               <Flex gap="2" align="start">
                                  <SewingPinFilledIcon className="text-red-500 mt-0.5" />
                                  <Box>
                                    <Text size="1" color="gray" className="block">Lokasi</Text>
                                    <Text size="1" className="block leading-tight text-gray-800">{item.lokasi?.alamat || "Lokasi tidak terdeteksi"}</Text>
                                  </Box>
                               </Flex>
                            </Box>
                          </div>

                          {/* --- ADMIN ACTIONS AREA --- */}
                          <div className="bg-blue-50 p-4 rounded-lg border border-blue-100 mt-2">
                             <Text size="1" weight="bold" className="uppercase text-blue-700 mb-2 flex items-center gap-2"><PersonIcon/> Tindakan Admin</Text>
                             <Flex direction="column" gap="3">
                                
                                {/* Status Changer - FIX TYPE */}
                                <Flex align="center" justify="between">
                                   <Text size="2" color="gray">Ubah Status:</Text>
                                   <Select.Root defaultValue={item.status} onValueChange={(val) => handleUpdateStatus(item.id, val as Absensi["status"])}>
                                      <Select.Trigger className="w-[140px]" />
                                      <Select.Content>
                                         <Select.Item value="VALID">Valid</Select.Item>
                                         <Select.Item value="TERLAMBAT">Terlambat</Select.Item>
                                         <Select.Item value="INVALID">Invalid</Select.Item>
                                      </Select.Content>
                                   </Select.Root>
                                </Flex>

                                <Separator size="4" />

                                {/* Delete Button */}
                                <Button color="red" variant="soft" className="w-full cursor-pointer" onClick={() => setDeleteId(item.id)}>
                                   <TrashIcon /> Hapus Log Kehadiran
                                </Button>
                             </Flex>
                          </div>
                        </div>
                      </div>

                      <div className="p-4 bg-gray-50 border-t border-gray-100 flex justify-end">
                        <Dialog.Close><Button variant="outline" color="gray" className="cursor-pointer">Tutup</Button></Dialog.Close>
                      </div>
                    </Dialog.Content>
                  </Dialog.Root>

                </Table.Cell>
              </Table.Row>
            ))}
          </Table.Body>
        </Table.Root>

        {filteredAbsensi.length === 0 && <Box className="text-center py-10 bg-gray-50/30"><ClockIcon className="h-6 w-6 text-gray-300 mx-auto mb-2" /><Text size="2" color="gray" weight="medium">Tidak ada data absensi yang ditemukan</Text></Box>}
        
        {filteredAbsensi.length > 0 && itemsPerPage !== "All" && (
          <Flex justify="between" align="center" p="3" className="border-t border-gray-100 bg-gray-50/30">
            <Text size="1" color="gray">Showing <span className="font-medium text-gray-900">{(currentPage - 1) * pageSize + 1}</span> to <span className="font-medium text-gray-900">{Math.min(currentPage * pageSize, totalItems)}</span> of <span className="font-medium text-gray-900">{totalItems}</span> entries</Text>
            <Flex gap="1" align="center">
              <Button variant="soft" color="gray" size="1" disabled={currentPage === 1} onClick={() => setCurrentPage(1)}><DoubleArrowLeftIcon width="12" height="12" /></Button>
              <Button variant="soft" color="gray" size="1" disabled={currentPage === 1} onClick={() => setCurrentPage(curr => Math.max(1, curr - 1))}><ChevronLeftIcon width="12" height="12" /></Button>
              <div className="flex gap-1 mx-1">{renderPaginationButtons()}</div>
              <Button variant="soft" color="gray" size="1" disabled={currentPage === totalPages} onClick={() => setCurrentPage(curr => Math.min(totalPages, curr + 1))}><ChevronRightIcon width="12" height="12" /></Button>
              <Button variant="soft" color="gray" size="1" disabled={currentPage === totalPages} onClick={() => setCurrentPage(totalPages)}><DoubleArrowRightIcon width="12" height="12" /></Button>
            </Flex>
          </Flex>
        )}
      </Card>

      {/* Delete Confirmation Alert */}
      <AlertDialog.Root open={!!deleteId} onOpenChange={(open) => !open && setDeleteId(null)}>
        <AlertDialog.Content maxWidth="450px">
          <AlertDialog.Title>Konfirmasi Hapus</AlertDialog.Title>
          <AlertDialog.Description size="2">Apakah Anda yakin ingin menghapus data absensi ini secara permanen?</AlertDialog.Description>
          <Flex gap="3" mt="4" justify="end">
            <AlertDialog.Cancel><Button variant="soft" color="gray" className="cursor-pointer">Batal</Button></AlertDialog.Cancel>
            <AlertDialog.Action><Button variant="solid" color="red" onClick={handleDelete} className="cursor-pointer">Ya, Hapus</Button></AlertDialog.Action>
          </Flex>
        </AlertDialog.Content>
      </AlertDialog.Root>
    </div>
  );
}