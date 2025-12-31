import { Text } from "@radix-ui/themes";

interface CircularProgressProps {
  percentage: number;
  label: string;
  subLabel?: string;
  size?: number; // Tambahan prop size
  color?: string;
}

export default function CircularProgress({ percentage, label, subLabel, size = 120 }: CircularProgressProps) {
  const radius = size * 0.4; // 40% dari container
  const stroke = size * 0.08; // Ketebalan 8%
  const normalizedRadius = radius - stroke / 2;
  const circumference = normalizedRadius * 2 * Math.PI;
  const strokeDashoffset = circumference - (percentage / 100) * circumference;

  // Warna dinamis
  let strokeColor = "#22c55e"; // Green
  if (percentage > 70) strokeColor = "#eab308"; // Yellow
  if (percentage > 90) strokeColor = "#ef4444"; // Red

  return (
    <div className="flex flex-col items-center justify-center">
      <div className="relative" style={{ width: size, height: size }}>
        {/* Background Circle */}
        <svg height="100%" width="100%" viewBox={`0 0 ${radius * 2} ${radius * 2}`} className="transform -rotate-90">
          <circle
            stroke="#f3f4f6"
            strokeWidth={stroke}
            fill="transparent"
            r={normalizedRadius}
            cx={radius}
            cy={radius}
          />
          {/* Progress Circle */}
          <circle
            stroke={strokeColor}
            strokeWidth={stroke}
            strokeDasharray={circumference + ' ' + circumference}
            style={{ strokeDashoffset, transition: 'stroke-dashoffset 0.8s ease-in-out' }}
            strokeLinecap="round"
            fill="transparent"
            r={normalizedRadius}
            cx={radius}
            cy={radius}
          />
        </svg>
        {/* Percentage Text */}
        <div className="absolute inset-0 flex flex-col items-center justify-center">
          <span className="font-bold text-gray-800" style={{ fontSize: size * 0.22 }}>
            {percentage.toFixed(1)}%
          </span>
        </div>
      </div>

      <div className="text-center mt-2">
        <Text weight="bold" size="2" className="text-gray-700 block">{label}</Text>
        {subLabel && <Text size="1" color="gray" className="text-[10px] opacity-70">{subLabel}</Text>}
      </div>
    </div>
  );
}