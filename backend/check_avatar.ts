import { prisma } from './src/lib/prisma'; // Adjust path if needed or just use relative

async function main() {
    const user = await prisma.user.findFirst({
        orderBy: { updatedAt: 'desc' },
        include: { pesertaMagang: true }
    });

    if (user) {
        console.log('User:', user.username);
        console.log('Role:', user.role);
        console.log('Avatar in User table:', user.avatar);
        console.log('Avatar in PesertaMagang table:', user.pesertaMagang?.avatar);
    } else {
        console.log('No user found');
    }
}

main()
    .catch(e => console.error(e))
    .finally(async () => {
        await prisma.$disconnect();
    });
