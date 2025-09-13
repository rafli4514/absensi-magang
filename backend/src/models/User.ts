import * as Sequelize from 'sequelize';
import sequelize from '../config/database';

interface UserAttributes {
  id: string;
  username: string;
  email: string;
  password: string;
  role: 'admin' | 'user';
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
}

interface UserInstance extends Sequelize.Model<UserAttributes>, UserAttributes {}

const User = sequelize.define<UserInstance>('User', {
  id: {
    type: Sequelize.UUID,
    defaultValue: Sequelize.UUIDV4,
    primaryKey: true,
  },
  username: {
    type: Sequelize.STRING,
    allowNull: false,
    unique: true,
  },
  email: {
    type: Sequelize.STRING,
    allowNull: false,
    unique: true,
    validate: {
      isEmail: true,
    },
  },
  password: {
    type: Sequelize.STRING,
    allowNull: false,
  },
  role: {
    type: Sequelize.ENUM('admin', 'user'),
    defaultValue: 'user',
  },
  isActive: {
    type: Sequelize.BOOLEAN,
    defaultValue: true,
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
  tableName: 'users',
  timestamps: true,
});

export default User;
