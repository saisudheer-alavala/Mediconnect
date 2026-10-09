import { PrismaClient } from '@prisma/client';
import { env } from './env';

declare global {
  // eslint-disable-next-line no-var
  var prismaGlobal: PrismaClient | undefined;
}

export const prisma =
  global.prismaGlobal ||
  new PrismaClient({
    log: env.NODE_ENV === 'development' ? ['query', 'error', 'warn'] : ['error'],
  });

if (env.NODE_ENV !== 'production') {
  global.prismaGlobal = prisma;
}

export const connectDatabase = async (): Promise<boolean> => {
  try {
    await prisma.$connect();
    console.log('PostgreSQL database connected successfully via Prisma.');
    return true;
  } catch (error) {
    console.error('Failed to connect to PostgreSQL database:', error);
    return false;
  }
};
