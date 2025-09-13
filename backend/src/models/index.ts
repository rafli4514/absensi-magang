import sequelize from '../config/database';
import User from './User';
import PesertaMagang from './PesertaMagang';
import Absensi from './Absensi';

// Export all models
export { User, PesertaMagang, Absensi };

// Export sequelize instance
export { sequelize };

// Database sync function
export const syncDatabase = async () => {
  try {
    await sequelize.authenticate();
    console.log('✅ Database connection established successfully.');

    // Sync all models
    await sequelize.sync({ alter: process.env.NODE_ENV === 'development' });
    console.log('✅ Database synchronized successfully.');
  } catch (error) {
    console.error('❌ Unable to connect to the database:', error);
    process.exit(1);
  }
};
