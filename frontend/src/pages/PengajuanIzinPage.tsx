import { useState } from "react";
import type { PengajuanIzin } from "../types/index";
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
} from "@radix-ui/themes";
import {
  EyeOpenIcon,
  FileTextIcon,
  CalendarIcon,
  MixerHorizontalIcon,
} from "@radix-ui/react-icons";
import Avatar from "../components/Avatar";

const StatusBadge = ({ status }: { status: PengajuanIzin["status"] }) => {
  const statusConfig = {
    PENDING: { color: "bg-yellow-100 text-yellow-800", label: "Menunggu" },
    DISETUJUI: { color: "bg-green-100 text-green-800", label: "Disetujui" },
    DITOLAK: { color: "bg-red-100 text-red-800", label: "Ditolak" },
  };
  const config = statusConfig[status] || { color: "bg-gray-100 text-gray-800", label: status };
  return <span className={`inline-flex px-2 py-0.5 text-[10px] font-semibold rounded-full ${config.color}`}>{config.label}</span>;
};

const TypeBadge = ({ tipe }: { tipe: PengajuanIzin["tipe"] }) => {
  const typeConfig = {
    SAKIT: { color: "bg-red-50 text-red-600 border-red-200", label: "Sakit" },
    IZIN: { color: "bg-blue-50 text-blue-600 border-blue-200", label: "Izin" },
    CUTI: { color: "bg-purple-50 text-purple-600 border-purple-200", label: "Cuti" },
    PULANG_CEPAT: { color: "bg-orange-50 text-orange-600 border-orange-200", label: "Pulang Cepat" },
    ALPHA: { color: "bg-red-100 text-red-700 border-red-300", label: "Alpha" },
    LAINNYA: { color: "bg-gray-50 text-gray-600 border-gray-200", label: "Lainnya" },
  };
  const config = typeConfig[tipe] || { color: "bg-gray-50 text-gray-600 border-gray-200", label: tipe };
  return <span className={`inline-flex px-2 py-0.5 text-[10px] font-semibold rounded-full border ${config.color}`}>{config.label}</span>;
};

export default function PengajuanIzinPage() {
  const [pengajuanIzin, setPengajuanIzin] = useState<PengajuanIzin[]>([]);
  const [searchTerm, setSearchTerm] = useState("");
  const [statusFilter, setStatusFilter] = useState<string>("Semua");
  const [typeFilter, setTypeFilter] = useState<string>("Semua");

  // REVISI SORTING:
  // Data difilter dulu, kemudian di-sort berdasarkan TANGGAL PENGAJUAN (diajukanPada) descending.
  // Kita TIDAK melakukan sort berdasarkan Status, agar item tidak loncat saat status berubah.
  const filteredPengajuanIzin = pengajuanIzin
    .filter((item) => {
      const matchesSearch = item.pesertaMagang?.nama.toLowerCase().includes(searchTerm.toLowerCase()) || item.alasan.toLowerCase().includes(searchTerm.toLowerCase());

      // Catatan: Jika Anda sedang memfilter "PENDING" dan meng-approve, item akan tetap hilang karena filter ini.
      // Jika Anda ingin item tetap muncul di list "PENDING" sesaat setelah diapprove (sebelum refresh), logic filternya perlu diubah sedikit,
      // tapi biasanya user ada di view "Semua" saat melakukan approval massal.
      const matchesStatus = statusFilter === "Semua" || item.status === statusFilter;
      const matchesType = typeFilter === "Semua" || item.tipe === typeFilter;
      return matchesSearch && matchesStatus && matchesType;
    })
    .sort((a, b) => {
      // Sort Stabil: Selalu berdasarkan Waktu Pengajuan Terbaru
      return new Date(b.diajukanPada).getTime() - new Date(a.diajukanPada).getTime();
    });

  const handleApprove = (id: string, catatan: string = "") => {
    setPengajuanIzin(pengajuanIzin.map((item) => item.id === id ? { ...item, status: "DISETUJUI", disetujuiOleh: "Admin", disetujuiPada: new Date().toISOString(), catatan, updatedAt: new Date().toISOString() } : item));
  };

  const handleReject = (id: string, catatan: string = "") => {
    setPengajuanIzin(pengajuanIzin.map((item) => item.id === id ? { ...item, status: "DITOLAK", disetujuiOleh: "Admin", disetujuiPada: new Date().toISOString(), catatan, updatedAt: new Date().toISOString() } : item));
  };

  const stats = {
    total: pengajuanIzin.length,
    pending: pengajuanIzin.filter((p) => p.status === "PENDING").length,
    disetujui: pengajuanIzin.filter((p) => p.status === "DISETUJUI").length,
    ditolak: pengajuanIzin.filter((p) => p.status === "DITOLAK").length,
  };

  return (
    <div className="space-y-4 pb-10">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-xl font-bold text-gray-900 tracking-tight">Manajemen Izin</h1>
          <p className="text-xs text-gray-500 mt-0.5">Kelola permohonan izin dari peserta magang</p>
        </div>
      </div>

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

      {/* Compact Filters */}
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
                    <Select.Item value="PULANG_CEPAT">Pulang Cepat</Select.Item>
                    <Select.Item value="ALPHA">Alpha</Select.Item>
                    <Select.Item value="LAINNYA">Lainnya</Select.Item>
                  </Select.Content>
                </Select.Root>
              </Flex>
            </Flex>
          </Flex>
        </Box>
      </Card>

      {/* Compact Table */}
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
              <Table.ColumnHeaderCell className="p-3">Diajukan</Table.ColumnHeaderCell>
              <Table.ColumnHeaderCell className="p-3" align="center">Aksi</Table.ColumnHeaderCell>
            </Table.Row>
          </Table.Header>
          <Table.Body>
            {filteredPengajuanIzin.map((item) => (
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
                <Table.Cell className="p-3 align-middle"><Text size="1" color="gray">{new Date(item.diajukanPada).toLocaleDateString("id-ID")}</Text></Table.Cell>
                <Table.Cell className="p-3 align-middle" align="center">
                  <Dialog.Root>
                    <Dialog.Trigger>
                      <IconButton size="1" variant="outline" color="blue"><EyeOpenIcon width="14" height="14" /></IconButton>
                    </Dialog.Trigger>
                    {/* Detail Review Dialog Content */}
                    <Dialog.Content className="max-w-xl">
                      <div className="text-center pb-4 border-b border-gray-200 mb-4">
                        <Dialog.Title className="text-lg font-bold">Review Izin</Dialog.Title>
                        <p className="text-xs text-gray-500">{item.pesertaMagang?.nama}</p>
                      </div>
                      {/* Compact Info Grid */}
                      <div className="grid grid-cols-2 gap-4 text-sm mb-6">
                        <div><p className="text-xs text-gray-500">Jenis</p><TypeBadge tipe={item.tipe} /></div>
                        <div><p className="text-xs text-gray-500">Status</p><StatusBadge status={item.status} /></div>
                        <div className="col-span-2"><p className="text-xs text-gray-500">Alasan</p><p className="bg-gray-50 p-2 rounded border border-gray-100">{item.alasan}</p></div>
                        {item.dokumenPendukung && <div className="col-span-2"><Button variant="outline" size="1"><FileTextIcon className="mr-2"/> {item.dokumenPendukung}</Button></div>}
                      </div>
                      {/* Actions */}
                      {/* Tampilkan tombol aksi meskipun status sudah bukan pending agar bisa revisi */}
                      <Flex gap="3" justify="end">
                           <Button color="red" variant="soft" onClick={() => handleReject(item.id)}>Tolak</Button>
                           <Button color="green" onClick={() => handleApprove(item.id)}>Setujui</Button>
                      </Flex>
                    </Dialog.Content>
                  </Dialog.Root>
                </Table.Cell>
              </Table.Row>
            ))}
          </Table.Body>
        </Table.Root>
        {filteredPengajuanIzin.length === 0 && <Box className="text-center py-10"><Text size="2" color="gray">Tidak ada data</Text></Box>}
      </Card>
    </div>
  );
}