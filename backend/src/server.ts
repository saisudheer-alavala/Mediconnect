import { createApp } from './app';
import { env } from './config/env';
import { connectDatabase, prisma } from './config/database';

const startServer = async () => {
  const app = createApp();

  // Test Database Connection
  await connectDatabase();

  const server = app.listen(env.PORT, () => {
    console.log(`===============================================`);
    console.log(` MediCare Connect REST API Server Online       `);
    console.log(` Port: ${env.PORT}                             `);
    console.log(` Environment: ${env.NODE_ENV}                  `);
    console.log(` Base URL: http://localhost:${env.PORT}/api/v1 `);
    console.log(` Health: http://localhost:${env.PORT}/api/v1/health `);
    console.log(` Database: Connected via Prisma             `);
    console.log(`===============================================`);
  });

  // Graceful Shutdown
  const handleShutdown = async (signal: string) => {
    console.log(`Received ${signal}. Shutting down gracefully...`);
    server.close(async () => {
      await prisma.$disconnect();
      console.log('Database disconnected. Process exiting.');
      process.exit(0);
    });
  };

  process.on('SIGINT', () => handleShutdown('SIGINT'));
  process.on('SIGTERM', () => handleShutdown('SIGTERM'));
};

startServer().catch((error) => {
  console.error('Fatal error starting MediCare server:', error);
  process.exit(1);
});
