import * as Sequelize from 'sequelize';
import sequelize from '../config/database';

interface PesertaMagangAttributes {
  id: string;
  nama: string;
  username: string;
  divisi: string;
  universitas: string;
  nomorHp: string;
  tanggalMulai: Date;
  tanggalSelesai: Date;
  status: 'Aktif' | 'Nonaktif' | 'Selesai';
  avatar?: string;
  createdAt: Date;
  updatedAt: Date;
}

interface PesertaMagangInstance extends Sequelize.Model<PesertaMagangAttributes>, PesertaMagangAttributes {}

const PesertaMagang = sequelize.define<PesertaMagangInstance>('PesertaMagang', {
  id: {
    type: Sequelize.UUID,
    defaultValue: Sequelize.UUIDV4,
    primaryKey: true,
  },
  nama: {
    type: Sequelize.STRING,
    allowNull: false,
  },
  username: {
    type: Sequelize.STRING,
    allowNull: false,
    unique: true,
  },
  divisi: {
    type: Sequelize.STRING,
    allowNull: false,
  },
  universitas: {
    type: Sequelize.STRING,
    allowNull: false,
  },
  nomorHp: {
    type: Sequelize.STRING,
    allowNull: false,
  },
  tanggalMulai: {
    type: Sequelize.DATE,
    allowNull: false,
  },
  tanggalSelesai: {
    type: Sequelize.DATE,
    allowNull: false,
  },
  status: {
    type: Sequelize.ENUM('Aktif', 'Nonaktif', 'Selesai'),
    defaultValue: 'Aktif',
  },
  avatar: {
    type: Sequelize.STRING,
    allowNull: true,
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
  tableName: 'peserta_magang',
  timestamps: true,
});

export default PesertaMagang;
