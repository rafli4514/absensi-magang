export interface ServerSpecs {
    hostname: string;
os: string;
cpuModel: string;
cpuCores: number;
totalRam: string;
totalStorage: string;
uptime: string;
}

export interface ResourceUsage {
memory: {
used: number; // in GB
total: number; // in GB
percentage: number;
};
swap: {
used: number;
total: number;
percentage: number;
};
storage: {
used: number; // in GB
total: number; // in GB
percentage: number;
};
}

export interface CpuNetworkStatus {
cpuLoad: number; // percentage
loadAverage: [number, number, number]; // 1m, 5m, 15m
network: {
received: string;
sent: string;
};
diskIo: {
read: string;
write: string;
};
}