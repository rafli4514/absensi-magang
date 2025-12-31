import { Request, Response } from 'express';
import si from 'systeminformation';

// 1. Ambil Spesifikasi Statis (CPU, RAM, OS)
export const getServerSpecs = async (req: Request, res: Response) => {
try {
const [osInfo, cpu, mem, diskLayout] = await Promise.all([
si.osInfo(),
      si.cpu(),
      si.mem(),
      si.diskLayout()
    ]);

    // Hitung Total Storage dari semua disk fisik
    const totalStorageBytes = diskLayout.reduce((acc, disk) => acc + disk.size, 0);
    const totalStorageGB = (totalStorageBytes / (1024 * 1024 * 1024)).toFixed(0);

    // Hitung Uptime
    const time = si.time();
    const uptimeSeconds = time.uptime;
    const days = Math.floor(uptimeSeconds / (3600 * 24));
    const hours = Math.floor((uptimeSeconds % (3600 * 24)) / 3600);

    const data = {
      hostname: osInfo.hostname,
      os: `${osInfo.distro} ${osInfo.release} (${osInfo.arch})`,
      cpuModel: `${cpu.manufacturer} ${cpu.brand}`,
      cpuCores: cpu.cores,
      totalRam: `${(mem.total / (1024 * 1024 * 1024)).toFixed(2)} GB`,
      totalStorage: `${totalStorageGB} GB`,
      uptime: `${days}d ${hours}h`
    };

    res.status(200).json({ success: true, data });
  } catch (error: any) {
    console.error("Spec Error:", error);
    res.status(500).json({ success: false, message: error.message });
  }
};

// 2. Ambil Statistik Real-time (CPU Load, RAM Usage)
export const getServerStats = async (req: Request, res: Response) => {
  try {
    const [currentLoad, mem, fsSize, networkStats, disksIO] = await Promise.all([
      si.currentLoad(),
      si.mem(),
      si.fsSize(),
      si.networkStats(),
      si.disksIO()
    ]);

    // Hitung Storage Used
    let totalUsed = 0;
    let totalSize = 0;
    fsSize.forEach(drive => {
      totalUsed += drive.used;
      totalSize += drive.size;
    });
    const storagePercent = totalSize > 0 ? (totalUsed / totalSize) * 100 : 0;

    // Network (ambil interface pertama yg aktif)
    const net = networkStats && networkStats.length > 0 ? networkStats[0] : { rx_bytes: 0, tx_bytes: 0 };

    const data = {
      resources: {
        memory: {
          used: Number((mem.active / (1024 * 1024 * 1024)).toFixed(2)),
          total: Number((mem.total / (1024 * 1024 * 1024)).toFixed(2)),
          percentage: Number(((mem.active / mem.total) * 100).toFixed(1))
        },
        swap: {
          used: Number((mem.swapused / (1024 * 1024 * 1024)).toFixed(2)),
          total: Number((mem.swaptotal / (1024 * 1024 * 1024)).toFixed(2)),
          percentage: mem.swaptotal > 0 ? Number(((mem.swapused / mem.swaptotal) * 100).toFixed(1)) : 0
        },
        storage: {
          used: Number((totalUsed / (1024 * 1024 * 1024)).toFixed(2)),
          total: Number((totalSize / (1024 * 1024 * 1024)).toFixed(2)),
          percentage: Number(storagePercent.toFixed(1))
        }
      },
      status: {
        cpuLoad: Number(currentLoad.currentLoad.toFixed(1)),
        loadAverage: currentLoad.cpus ? currentLoad.cpus.map(c => Number(c.load.toFixed(2))).slice(0, 3) : [0, 0, 0],
        network: {
          received: `${(net.rx_bytes / (1024 * 1024)).toFixed(2)} MB`,
          sent: `${(net.tx_bytes / (1024 * 1024)).toFixed(2)} MB`
        },
        diskIo: {
          read: disksIO ? `${(disksIO.rIO_sec || 0).toFixed(2)} MB/s` : "0 MB/s",
          write: disksIO ? `${(disksIO.wIO_sec || 0).toFixed(2)} MB/s` : "0 MB/s"
        }
      }
    };

    res.status(200).json({ success: true, data });
  } catch (error: any) {
    console.error("Stats Error:", error);
    res.status(500).json({ success: false, message: error.message });
  }
};