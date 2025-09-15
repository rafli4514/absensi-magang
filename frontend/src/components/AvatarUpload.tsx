import React, { useRef, useState } from "react";
import { Camera, Upload, X } from "lucide-react";
import { Button } from "@radix-ui/themes";
import Avatar from "./Avatar";

interface AvatarUploadProps {
  src?: string | null;
  alt: string;
  name: string;
  size?: "sm" | "md" | "lg" | "xl";
  onUpload: (file: File) => Promise<void>;
  onRemove?: () => void;
  disabled?: boolean;
  className?: string;
}

export default function AvatarUpload({
  src,
  alt,
  name,
  size = "lg",
  onUpload,
  onRemove,
  disabled = false,
  className = ""
}: AvatarUploadProps) {
  const [isUploading, setIsUploading] = useState(false);
  const [previewUrl, setPreviewUrl] = useState<string | null>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const handleFileSelect = () => {
    if (disabled || isUploading) return;
    fileInputRef.current?.click();
  };

  const handleFileChange = async (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (!file) return;

    // Validate file type
    if (!file.type.startsWith('image/')) {
      alert('File harus berupa gambar!');
      return;
    }

    // Validate file size (max 5MB)
    if (file.size > 5 * 1024 * 1024) {
      alert('Ukuran file maksimal 5MB!');
      return;
    }

    try {
      setIsUploading(true);
      
      // Create preview URL
      const url = URL.createObjectURL(file);
      setPreviewUrl(url);
      
      // Upload file
      await onUpload(file);
      
    } catch (error) {
      console.error('Upload error:', error);
      alert('Gagal mengupload avatar!');
    } finally {
      setIsUploading(false);
      // Clear file input
      if (fileInputRef.current) {
        fileInputRef.current.value = '';
      }
    }
  };

  const handleRemove = () => {
    if (previewUrl) {
      URL.revokeObjectURL(previewUrl);
      setPreviewUrl(null);
    }
    onRemove?.();
  };

  const displaySrc = previewUrl || src;

  return (
    <div className={`relative group ${className}`}>
      <div className="relative">
        <Avatar
          src={displaySrc}
          alt={alt}
          name={name}
          size={size}
          showBorder={true}
          showHover={true}
        />
        
        {/* Upload overlay */}
        {!disabled && (
          <div className="absolute inset-0 bg-black bg-opacity-50 rounded-full flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity duration-200">
            <div className="flex gap-2">
              <Button
                size="1"
                variant="solid"
                color="indigo"
                onClick={handleFileSelect}
                disabled={isUploading}
                className="p-2"
              >
                {isUploading ? (
                  <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></div>
                ) : (
                  <Camera className="h-4 w-4" />
                )}
              </Button>
              
              {displaySrc && onRemove && (
                <Button
                  size="1"
                  variant="solid"
                  color="red"
                  onClick={handleRemove}
                  className="p-2"
                >
                  <X className="h-4 w-4" />
                </Button>
              )}
            </div>
          </div>
        )}
      </div>

      {/* Hidden file input */}
      <input
        ref={fileInputRef}
        type="file"
        accept="image/*"
        onChange={handleFileChange}
        className="hidden"
        disabled={disabled}
      />

      {/* Upload status */}
      {isUploading && (
        <div className="absolute -bottom-2 left-1/2 transform -translate-x-1/2">
          <div className="bg-blue-600 text-white text-xs px-2 py-1 rounded-full flex items-center gap-1">
            <Upload className="h-3 w-3" />
            Uploading...
          </div>
        </div>
      )}
    </div>
  );
}
