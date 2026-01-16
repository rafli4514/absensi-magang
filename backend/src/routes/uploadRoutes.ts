import express, { Request, Response } from 'express';
import { upload } from '../middleware/upload';

const router = express.Router();

// Upload Single Image
// Upload Single Image
router.post('/image', (req: Request, res: Response) => {
    // DEBUG LOGGING
    console.log('--- Upload Request Received ---');
    console.log('Headers:', JSON.stringify(req.headers));

    upload.single('image')(req, res, (err: any) => {
        if (err) {
            console.error('Multer Error:', err);
            if (err.code === 'LIMIT_FILE_SIZE') {
                res.status(400).json({ success: false, message: 'File too large. Max 5MB.' });
                return;
            }
            res.status(400).json({ success: false, message: err.message });
            return;
        }

        try {
            if (!req.file) {
                res.status(400).json({
                    success: false,
                    message: 'No image file provided'
                });
                return;
            }

            // Construct URL
            const protocol = req.protocol;
            // Use detected LAN IP for development stability
            const host = '10.64.75.71:3000';
            const fileUrl = `${protocol}://${host}/uploads/${req.file.filename}`;

            res.status(200).json({
                success: true,
                message: 'Image uploaded successfully',
                data: {
                    url: fileUrl,
                    filename: req.file.filename,
                    mimetype: req.file.mimetype,
                    size: req.file.size
                }
            });
        } catch (error) {
            console.error('Upload processing error:', error);
            res.status(500).json({
                success: false,
                message: 'Failed to upload image'
            });
        }
    });
});

export default router;
