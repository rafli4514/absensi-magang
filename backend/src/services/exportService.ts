import { Response } from "express";
import PDFDocument from "pdfkit";
import { Parser } from "json2csv";

export class ExportService {
    /**
     * Generate Logbook PDF Report
     */
    static generateLogbookPDF(
        data: any[],
        meta: {
            startDate?: string;
            endDate?: string;
            requestedBy: string;
            role: string
        },
        res: Response
    ) {
        const doc = new PDFDocument({ margin: 50 });

        const filename = `Logbook_Report_${Date.now()}.pdf`;
        res.setHeader("Content-disposition", `attachment; filename="${filename}"`);
        res.setHeader("Content-type", "application/pdf");

        doc.pipe(res);

        // -- Header --
        doc.fontSize(20).text("Laporan Kegiatan Magang", { align: "center" });
        doc.moveDown();

        doc.fontSize(12).text(`Periode: ${meta.startDate || '-'} s/d ${meta.endDate || '-'}`);
        doc.text(`Dicetak Oleh: ${meta.requestedBy} (${meta.role})`);
        doc.text(`Tanggal Cetak: ${new Date().toLocaleString()}`);
        doc.moveDown(2);

        // -- Table Logic (Simple) --
        // PDFKit doesn't have built-in tables, so we simulate one or list items.
        // For simplicity: Listing items card-style.

        data.forEach((log, index) => {
            doc
                .fontSize(14)
                .text(`${index + 1}. ${log.tanggal} - ${log.kegiatan}`, { underline: true });

            doc.fontSize(10).text(`Peserta: ${log.pesertaMagang?.nama || 'N/A'}`);
            doc.text(`Divisi: ${log.pesertaMagang?.divisi || 'N/A'}`);

            doc.moveDown(0.5);
            doc.fontSize(11).text("Deskripsi:");
            doc.fontSize(10).text(log.deskripsi, { align: 'justify' });

            if (log.durasi) doc.text(`Durasi: ${log.durasi}`);
            if (log.status) doc.text(`Status: ${log.status}`);

            doc.moveDown(1.5);

            // Page break check (rough estimation)
            if (doc.y > 700) doc.addPage();
        });

        if (data.length === 0) {
            doc.text("Tidak ada data kegiatan pada periode ini.", { align: "center" });
        }

        doc.end();
    }

    /**
     * Generate CSV Data
     */
    static generateCSV(data: any[], fields: string[], filenamePrefix: string, res: Response) {
        try {
            const json2csvParser = new Parser({ fields });
            const csv = json2csvParser.parse(data);

            const filename = `${filenamePrefix}_${Date.now()}.csv`;
            res.header("Content-Type", "text/csv");
            res.attachment(filename);

            res.send(csv);
        } catch (error) {
            console.error("CSV Gen Error:", error);
            res.status(500).json({ success: false, message: "Gagal generate CSV" });
        }
    }
}
