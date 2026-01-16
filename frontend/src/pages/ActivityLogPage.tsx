import { useState, useEffect } from "react";
import { Download, Search, CheckCircle, AlertCircle, Clock, FileText } from "lucide-react";
import {
    Card,
    Grid,
    Text,
    Button,
    Flex,
    Badge,
    ScrollArea,
    Avatar,
    Select,
    DropdownMenu
} from "@radix-ui/themes";
import { activityService } from "../services/activity";
import type { ActivityLog } from "../types";

export default function ActivityLogPage() {
    const [logs, setLogs] = useState<ActivityLog[]>([]);
    const [loading, setLoading] = useState(true);
    const [filterStartDate, setFilterStartDate] = useState("");
    const [filterEndDate, setFilterEndDate] = useState("");
    const [userIdFilter, setUserIdFilter] = useState(""); // For admins to filter by specific user

    const [page, setPage] = useState(1);
    const [totalPages, setTotalPages] = useState(1);

    const fetchData = async () => {
        try {
            setLoading(true);
            const res = await activityService.getTimeline(page, 20, userIdFilter || undefined);
            if (res.data) {
                setLogs(res.data.data);
                setTotalPages(res.data.pagination.totalPages);
            }
        } catch (err) {
            console.error("Failed to fetch activity logs", err);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchData();
    }, [page, userIdFilter]);

    const handleExport = async (format: 'csv' | 'pdf') => {
        try {
            // If exporting activity, we usually use CSV. PDF is for Logbook Reports. 
            // The prompt requested Export for both Logbook and Activity.
            // PDF/CSV for Logbook. CSV for Activity.
            // Let's implement CSV export for Activity here.

            const response = await activityService.exportActivity(filterStartDate, filterEndDate);

            // Create blob link to download
            const url = window.URL.createObjectURL(new Blob([response.data]));
            const link = document.createElement('a');
            link.href = url;
            link.setAttribute('download', `Activity_Log_${new Date().toISOString()}.csv`);
            document.body.appendChild(link);
            link.click();
            link.remove();
        } catch (e) {
            console.error("Export failed", e);
            alert("Gagal mengunduh export");
        }
    };

    const getActionIcon = (action: string) => {
        if (action.includes("CREATE")) return <CheckCircle className="text-green-500 w-4 h-4" />;
        if (action.includes("DELETE")) return <AlertCircle className="text-red-500 w-4 h-4" />;
        if (action.includes("UPDATE")) return <Clock className="text-blue-500 w-4 h-4" />;
        return <FileText className="text-gray-500 w-4 h-4" />;
    };

    return (
        <div className="space-y-6 pb-20">
            <div className="flex justify-between items-center">
                <div>
                    <h1 className="text-2xl font-bold text-gray-800">Activity Timeline</h1>
                    <p className="text-gray-500 text-sm">Rekam jejak aktivitas sistem secara real-time</p>
                </div>
                <div className="flex gap-2">
                    <div className="flex items-center gap-1 bg-white border border-gray-200 rounded-md px-2 py-1 h-9">
                        <span className="text-xs text-gray-400">Filter Tanggal:</span>
                        <input type="date" className="text-xs border-none outline-none" value={filterStartDate} onChange={e => setFilterStartDate(e.target.value)} />
                        <span className="text-gray-300">-</span>
                        <input type="date" className="text-xs border-none outline-none" value={filterEndDate} onChange={e => setFilterEndDate(e.target.value)} />
                    </div>

                    <DropdownMenu.Root>
                        <DropdownMenu.Trigger>
                            <Button variant="soft" color="gray" className="cursor-pointer">
                                <Download className="w-4 h-4 mr-1" /> Export CSV
                            </Button>
                        </DropdownMenu.Trigger>
                        <DropdownMenu.Content>
                            <DropdownMenu.Item onClick={() => handleExport('csv')}>Download CSV</DropdownMenu.Item>
                        </DropdownMenu.Content>
                    </DropdownMenu.Root>
                </div>
            </div>

            <Card size="2" className="bg-gray-50/50 min-h-[500px]">
                {loading ? (
                    <div className="flex justify-center p-10"><div className="animate-spin h-6 w-6 border-2 border-blue-500 rounded-full border-t-transparent"></div></div>
                ) : (
                    <div className="relative border-l-2 border-gray-200 ml-4 space-y-6">
                        {logs.map((log) => (
                            <div key={log.id} className="mb-8 ml-6 relative group">
                                <span className="absolute -left-[31px] flex items-center justify-center w-8 h-8 bg-white rounded-full ring-4 ring-white border border-gray-200">
                                    {getActionIcon(log.action)}
                                </span>
                                <div className="bg-white p-4 rounded-lg border border-gray-100 shadow-sm hover:shadow-md transition-all">
                                    <div className="flex justify-between items-start mb-1">
                                        <div className="flex items-center gap-2">
                                            <Badge size="1" color={log.action.includes("DELETE") ? "red" : "blue"}>{log.action}</Badge>
                                            <span className="text-xs text-gray-400 font-mono">{new Date(log.createdAt).toLocaleString()}</span>
                                        </div>
                                        {/* <Badge variant="outline" color="gray">{log.entityType}</Badge> */}
                                    </div>

                                    <h3 className="text-sm font-semibold text-gray-900 mt-1">{log.description}</h3>

                                    <div className="mt-3 flex items-center gap-2 pt-3 border-t border-gray-50">
                                        <Avatar
                                            src={log.user?.avatar}
                                            fallback={log.user?.username?.substring(0, 2).toUpperCase() || "??"}
                                            size="1"
                                            radius="full"
                                        />
                                        <div className="flex flex-col">
                                            <span className="text-xs font-medium text-gray-700">{log.user?.username || "Unknown System User"}</span>
                                            <span className="text-[10px] text-gray-400">{log.user?.role}</span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        ))}

                        {logs.length === 0 && (
                            <div className="ml-6 py-10 text-gray-400 text-sm">Belum ada aktivitas tercatat.</div>
                        )}
                    </div>
                )}

                {/* Simple Pagination */}
                <div className="flex justify-end gap-2 mt-4 pr-4">
                    <Button disabled={page === 1} onClick={() => setPage(p => p - 1)} variant="soft" color="gray">Prev</Button>
                    <span className="text-sm self-center">Page {page} of {totalPages}</span>
                    <Button disabled={page >= totalPages} onClick={() => setPage(p => p + 1)} variant="soft" color="gray">Next</Button>
                </div>
            </Card>
        </div>
    );
}
