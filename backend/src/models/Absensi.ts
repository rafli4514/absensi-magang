import * as Sequelize from 'sequelize';
import sequelize from '../config/database';
import PesertaMagang from './PesertaMagang';

interface AbsensiAttributes {
  id: string;
  pesertaMagangId: string;
  tipe: 'Masuk' | 'Keluar' | 'Izin' | 'Sakit' | 'Cuti';
  timestamp: Date;
  lokasi?: string;
  selfieUrl?: string;
  qrCodeData?: string;
  status: 'valid' | 'Terlambat' | 'invalid';
  createdAt: Date;
  updatedAt: Date;
  pesertaMagang?: any;
}

interface AbsensiInstance extends Sequelize.Model<AbsensiAttributes>, AbsensiAttributes {}

const Absensi = sequelize.define<AbsensiInstance>('Absensi', {
  id: {
    type: Sequelize.UUID,
    defaultValue: Sequelize.UUIDV4,
    primaryKey: true,
  },
  pesertaMagangId: {
    type: Sequelize.UUID,
    allowNull: false,
    references: {
      model: PesertaMagang,
      key: 'id',
    },
  },
  tipe: {
    type: Sequelize.ENUM('Masuk', 'Keluar', 'Izin', 'Sakit', 'Cuti'),
    allowNull: false,
  },
  timestamp: {
    type: Sequelize.DATE,
    allowNull: false,
  },
  lokasi: {
    type: Sequelize.TEXT,
    allowNull: true,
  },
  selfieUrl: {
    type: Sequelize.STRING,
    allowNull: true,
  },
  qrCodeData: {
    type: Sequelize.STRING,
    allowNull: true,
  },
  status: {
    type: Sequelize.ENUM('valid', 'Terlambat', 'invalid'),
    defaultValue: 'valid',
  },
  createdAt: {
    type: Sequelize.DATE,
    defaultValue: Sequelize.NOW,
  },
  updatedAt: {
    type: Sequelize.DATE,
    defaultValue: Sequelize.NOW,
  },
}, {
  tableName: 'absensi',
  timestamps: true,
});

// Define associations
Absensi.belongsTo(PesertaMagang, {
  foreignKey: 'pesertaMagangId',
  as: 'pesertaMagang',
});

export default Absensi;
