import {
  PrismaClient,
  Role,
} from "@prisma/client";
import bcrypt from "bcryptjs";

const prisma = new PrismaClient();

async function main() {
  console.log("🌱 Starting database seeding...");

  // Hash admin password
  const hashedAdminPassword = await bcrypt.hash("admin123", 10);

  // === CREATE ADMIN USER ===
  const adminUser = await prisma.user.upsert({
    where: { username: "admin" },
    update: {},
    create: {
      username: "admin",
      password: hashedAdminPassword,
      role: Role.ADMIN,
      isActive: true,
    },
  });
  console.log("✅ Admin user created:", adminUser.username);

  console.log("🎉 Database seeding completed successfully!");
  console.log("\n📝 Admin Credentials:");
  console.log("Username: admin");
  console.log("Password: admin123");
}

main()
  .catch((e) => {
    console.error("❌ Error during seeding:", e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
