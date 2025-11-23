import { useState } from "react";
import { User } from "lucide-react";
import { cn } from "../lib/utils";

interface AvatarProps {
  src?: string | null;
  alt: string;
  name: string;
  size?: "sm" | "md" | "lg" | "xl";
  className?: string;
  showBorder?: boolean;
  showHover?: boolean;
}

const sizeClasses = {
  sm: "h-8 w-8",
  md: "h-12 w-12", 
  lg: "h-16 w-16",
  xl: "h-40 w-40"
};

const iconSizes = {
  sm: "h-4 w-4",
  md: "h-6 w-6",
  lg: "h-8 w-8", 
  xl: "h-20 w-20"
};

const textSizes = {
  sm: "text-xs",
  md: "text-sm",
  lg: "text-lg",
  xl: "text-2xl"
};

const borderClasses = {
  sm: "border-2",
  md: "border-2", 
  lg: "border-2",
  xl: "border-4"
};

export default function Avatar({ 
  src, 
  alt, 
  name, 
  size = "md", 
  className = "",
  showBorder = true,
  showHover = true
}: AvatarProps) {
  const [imageError, setImageError] = useState(false);

  const handleImageError = () => {
    console.error('❌ Avatar failed to load:', src);
    setImageError(true);
  };

  const getInitials = (name: string) => {
    return name
      .split(" ")
      .map((n: string) => n[0])
      .join("")
      .toUpperCase()
      .slice(0, 2);
  };

  const baseClasses = cn(
    "rounded-full object-cover flex items-center justify-center relative overflow-hidden",
    sizeClasses[size],
    showBorder && borderClasses[size],
    showBorder && "border-white shadow-lg",
    showHover && "hover:shadow-xl transition-all duration-300 transform hover:scale-105",
    className
  );

  const fallbackClasses = cn(
    "rounded-full flex items-center justify-center",
    sizeClasses[size],
    showBorder && borderClasses[size],
    showBorder && "border-white shadow-lg",
    "bg-gradient-to-br from-blue-100 to-blue-200"
  );

  // Validasi src
  const isValidSrc = src && 
    src.trim() !== '' && 
    src !== 'null' && 
    src !== 'undefined' &&
    !src.includes('via.placeholder.com') &&
    !src.includes('placeholder') &&
    (src.startsWith('http://') || src.startsWith('https://') || src.startsWith('/'));

  // Jika ada src yang valid dan tidak ada error, tampilkan gambar
  if (isValidSrc && !imageError) {
    return (
      <img
        src={src}
        alt={alt}
        className={baseClasses}
        onError={handleImageError}
        onLoad={() => console.log('✅ Avatar loaded successfully:', src)}
        crossOrigin="anonymous"
      />
    );
  }

  // Fallback: tampilkan inisial nama atau ikon user
  return (
    <div className={fallbackClasses}>
      {name ? (
        <span className={cn(textSizes[size], "font-bold text-blue-600")}>
          {getInitials(name)}
        </span>
      ) : (
        <User className={cn(iconSizes[size], "text-blue-600")} />
      )}
    </div>
  );
}
