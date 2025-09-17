import { useState, useEffect } from "react";
import { useParams } from "react-router-dom";
import type { PesertaMagang, Absensi } from "../types";
import {
  Box,
  Card,
  Flex,
  Grid,
  Table,
  Text,
  TextField,
  Badge,
  Separator,
} from "@radix-ui/themes";
import { ClockIcon, MagnifyingGlassIcon } from "@radix-ui/react-icons";
import { Calendar, Clock, MapPin, Phone, GraduationCap } from "lucide-react";

// Import services
import pesertaMagangService from "../services/pesertaMagangService";
import absensiService from "../services/absensiService";
import Avatar from "../components/Avatar";

export default function ProfilPesertaMagangPage() {
  const { id } = useParams<{ id: string }>();
  const [peserta, setPeserta] = useState<PesertaMagang | null>(null);
  const [absensi, setAbsensi] = useState<Absensi[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [searchTerm, setSearchTerm] = useState("");
  const [statusFilter] = useState<string>("Semua");

  // Fetch data on component mount
  useEffect(() => {
    if (id) {
      fetchData();
    }
  }, [id]);

  const fetchData = async () => {
    if (!id) return;

    try {
      setLoading(true);
      setError(null);

      // Fetch peserta and absensi data in parallel
      const [pesertaResponse, absensiResponse] = await Promise.all([
        pesertaMagangService.getPesertaMagangById(id),
        absensiService.getAbsensi({ pesertaMagangId: id }),
      ]);

      if (pesertaResponse.success && pesertaResponse.data) {
        setPeserta(pesertaResponse.data);
      }

      if (absensiResponse.success && absensiResponse.data) {
        setAbsensi(absensiResponse.data);
      }
    } catch (error: unknown) {
      console.error("Fetch profil data error:", error);
      setError("Failed to fetch profil data");
    } finally {
      setLoading(false);
    }
  };

  const filteredAbsensi = absensi.filter((item) => {
    const matchesSearch = item.tipe
      .toLowerCase()
      .includes(searchTerm.toLowerCase());

    const matchesStatus =
      statusFilter === "Semua" || item.status === statusFilter;

    return matchesSearch && matchesStatus;
  });

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-96">
        <Card className="p-8">
          <Flex direction="column" align="center" gap="4">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
            <Text size="3" weight="medium" color="gray">
              Memuat profil peserta...
            </Text>
          </Flex>
        </Card>
      </div>
    );
  }

  if (error) {
    return (
      <div className="flex items-center justify-center min-h-96">
        <Card className="p-8">
          <Flex direction="column" align="center" gap="4">
            <div className="h-12 w-12 rounded-full bg-red-100 flex items-center justify-center">
              <Text size="4" color="red">
                !
              </Text>
            </div>
            <Text size="3" weight="medium" color="red">
              Error: {error}
            </Text>
            <button
              onClick={fetchData}
              className="px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors font-medium"
            >
              Coba Lagi
            </button>
          </Flex>
        </Card>
      </div>
    );
  }

  if (!peserta) {
    return (
      <div className="flex items-center justify-center min-h-96">
        <Card className="p-8">
          <Flex direction="column" align="center" gap="4">
            <Avatar
              src={null}
              alt="User not found"
              name=""
              size="lg"
              showBorder={false}
              showHover={false}
            />
            <Text size="3" weight="medium" color="gray">
              Peserta tidak ditemukan
            </Text>
          </Flex>
        </Card>
      </div>
    );
  }

  return (
    <div className="space-y-8">
      {/* Page header */}
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Manajemen peserta </h1>
        <p className="text-gray-600">Kelola data peserta magang/PKL</p>
      </div>

      {/* Profile Card */}
      <Card className="shadow-lg">
        <Box p="6">
          <Flex direction="column" gap="6">
            {/* Profile Header */}
            <Flex align="center" gap="6">
              <Avatar
                src={peserta.avatar}
                alt={peserta.nama}
                name={peserta.nama}
                size="xl"
                showBorder={true}
                showHover={true}
              />

              <Box className="flex-1">
                <Flex direction="column" gap="2">
                  <Text size="6" weight="bold" className="text-gray-900">
                    {peserta.nama}
                  </Text>
                  <Text size="3" color="gray" className="font-medium">
                    @{peserta.username}
                  </Text>
                  <Flex align="center" gap="2" wrap="wrap">
                    <Badge color="blue" variant="soft" size="2">
                      {peserta.divisi}
                    </Badge>
                    <Badge color="purple" variant="soft" size="2">
                      {peserta.Instansi}
                    </Badge>
                  </Flex>
                </Flex>
              </Box>
            </Flex>

            <Separator size="4" />

            {/* Profile Details */}
            <Grid columns={{ initial: "1", md: "2" }} gap="6">
              <Box>
                <Text
                  size="3"
                  weight="bold"
                  color="gray"
                  mb="4"
                  className="flex items-center gap-2"
                >
                  <Phone className="h-4 w-4" />
                  Informasi Kontak
                </Text>
                <Flex direction="column" gap="3">
                  <Flex
                    align="center"
                    gap="3"
                    className="p-3 bg-gray-50 rounded-lg"
                  >
                    <Phone className="h-5 w-5 text-blue-600" />
                    <Text size="2" weight="medium">
                      {peserta.nomorHp}
                    </Text>
                  </Flex>
                  <Flex
                    align="center"
                    gap="3"
                    className="p-3 bg-gray-50 rounded-lg"
                  >
                    <GraduationCap className="h-5 w-5 text-green-600" />
                    <Text size="2" weight="medium">
                      {peserta.Instansi}
                    </Text>
                  </Flex>
                </Flex>
              </Box>

              <Box>
                <Text
                  size="3"
                  weight="bold"
                  color="gray"
                  mb="4"
                  className="flex items-center gap-2"
                >
                  <Calendar className="h-4 w-4" />
                  Periode Magang
                </Text>
                <Flex direction="column" gap="3">
                  <Flex
                    align="center"
                    gap="3"
                    className="p-3 bg-gray-50 rounded-lg"
                  >
                    <Calendar className="h-5 w-5 text-purple-600" />
                    <Text size="2" weight="medium">
                      {new Date(peserta.tanggalMulai).toLocaleDateString(
                        "id-ID"
                      )}{" "}
                      -{" "}
                      {new Date(peserta.tanggalSelesai).toLocaleDateString(
                        "id-ID"
                      )}
                    </Text>
                  </Flex>
                  <Flex
                    align="center"
                    gap="3"
                    className="p-3 bg-gray-50 rounded-lg"
                  >
                    <Clock className="h-5 w-5 text-orange-600" />
                    <Text size="2" weight="medium">
                      Status:
                      <Badge
                        color={
                          peserta.status === "AKTIF"
                            ? "green"
                            : peserta.status === "NONAKTIF"
                            ? "red"
                            : "gray"
                        }
                        variant="soft"
                        size="1"
                        className="ml-2"
                      >
                        {peserta.status}
                      </Badge>
                    </Text>
                  </Flex>
                </Flex>
              </Box>
            </Grid>
          </Flex>
        </Box>
      </Card>

      {/* Attendance Records */}
      <Card className="shadow-lg">
        <Box p="6">
          <Flex direction="column" gap="6">
            {/* Header */}
            <Flex align="center" justify="between">
              <Text size="4" weight="bold" className="text-gray-900">
                Riwayat Absensi
              </Text>
              <Badge color="blue" variant="soft" size="2">
                {filteredAbsensi.length} dari {absensi.length} catatan
              </Badge>
            </Flex>

            {/* Filters */}
            <Flex gap="4" wrap="wrap">
              <TextField.Root
                placeholder="Cari berdasarkan tipe absensi..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="flex-1 min-w-64"
                size="3"
              >
                <TextField.Slot>
                  <MagnifyingGlassIcon height="16" width="16" />
                </TextField.Slot>
              </TextField.Root>
            </Flex>

            {/* Attendance Table */}
            <Box className="overflow-x-auto">
              <Table.Root variant="ghost">
                <Table.Header>
                  <Table.Row>
                    <Table.ColumnHeaderCell className="font-semibold">
                      Tanggal & Waktu
                    </Table.ColumnHeaderCell>
                    <Table.ColumnHeaderCell className="font-semibold">
                      Tipe
                    </Table.ColumnHeaderCell>
                    <Table.ColumnHeaderCell className="font-semibold">
                      Status
                    </Table.ColumnHeaderCell>
                    <Table.ColumnHeaderCell className="font-semibold">
                      Lokasi
                    </Table.ColumnHeaderCell>
                  </Table.Row>
                </Table.Header>
                <Table.Body>
                  {filteredAbsensi.map((item) => (
                    <Table.Row key={item.id} className="hover:bg-gray-50">
                      <Table.Cell>
                        <Flex direction="column" gap="1">
                          <Text
                            size="2"
                            weight="bold"
                            className="text-gray-900"
                          >
                            {new Date(item.timestamp).toLocaleDateString(
                              "id-ID",
                              {
                                weekday: "long",
                                year: "numeric",
                                month: "long",
                                day: "numeric",
                              }
                            )}
                          </Text>
                          <Text size="1" color="gray" className="font-medium">
                            {new Date(item.timestamp).toLocaleTimeString(
                              "id-ID",
                              {
                                hour: "2-digit",
                                minute: "2-digit",
                              }
                            )}
                          </Text>
                        </Flex>
                      </Table.Cell>
                      <Table.Cell>
                        <Badge
                          color={item.tipe === "MASUK" ? "green" : "red"}
                          variant="soft"
                          size="2"
                        >
                          {item.tipe}
                        </Badge>
                      </Table.Cell>
                      <Table.Cell>
                        <Badge
                          color={item.status === "VALID" ? "green" : "red"}
                          variant="soft"
                          size="2"
                        >
                          {item.status}
                        </Badge>
                      </Table.Cell>
                      <Table.Cell>
                        <Flex align="center" gap="2">
                          <MapPin className="h-4 w-4 text-gray-500" />
                          <Text size="2" color="gray" className="font-medium">
                            {item.lokasi?.alamat || "Tidak tersedia"}
                          </Text>
                        </Flex>
                      </Table.Cell>
                    </Table.Row>
                  ))}
                </Table.Body>
              </Table.Root>
            </Box>

            {filteredAbsensi.length === 0 && (
              <Box className="text-center py-12">
                <ClockIcon className="h-12 w-12 text-gray-400 mx-auto mb-4" />
                <Flex direction="column" justify="center">
                  <Text size="3" color="gray" weight="medium">
                    Tidak ada data absensi yang ditemukan
                  </Text>
                  <Text size="2" color="gray" className="mt-2">
                    {searchTerm
                      ? "Coba ubah kata kunci pencarian"
                      : "Belum ada riwayat absensi untuk peserta ini"}
                  </Text>
                </Flex>
              </Box>
            )}
          </Flex>
        </Box>
      </Card>
    </div>
  );
}
