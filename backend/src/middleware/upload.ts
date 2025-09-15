import multer = require('multer');
import path = require('path');

// Storage configuration
const storage = multer.diskStorage({
  destination: (req: any, file: any, cb: any) => {
    const uploadPath = path.join(__dirname, '..', 'uploads');
    console.log('Upload destination:', uploadPath);
    cb(null, uploadPath);
  },
  filename: (req: any, file: any, cb: any) => {
    // Generate unique filename
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
  }
});

// File filter
const fileFilter = (req: any, file: any, cb: any) => {
  // Allow only images
  if (file.mimetype && file.mimetype.startsWith('image/')) {
    cb(null, true);
  } else {
    cb(new Error('Only image files are allowed!'));
  }
};

// Upload middleware
export const upload = multer({
  storage,
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB
  },
  fileFilter,
});

// Single file upload
export const uploadSingle = (fieldName: string) => upload.single(fieldName);

// Multiple files upload
export const uploadMultiple = (fieldName: string, maxCount: number = 5) =>
  upload.array(fieldName, maxCount);
