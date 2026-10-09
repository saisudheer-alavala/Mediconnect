"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const app_1 = require("./app");
const env_1 = require("./config/env");
const database_1 = require("./config/database");
const startServer = async () => {
    const app = (0, app_1.createApp)();
    // Test Database Connection
    await (0, database_1.connectDatabase)();
    const server = app.listen(env_1.env.PORT, () => {
        console.log(`===============================================`);
        console.log(` MediCare Connect REST API Server Online       `);
        console.log(` Port: ${env_1.env.PORT}                             `);
        console.log(` Environment: ${env_1.env.NODE_ENV}                  `);
        console.log(` Base URL: http://localhost:${env_1.env.PORT}/api/v1 `);
        console.log(` Health: http://localhost:${env_1.env.PORT}/api/v1/health `);
        console.log(`===============================================`);
    });
    // Graceful Shutdown
    const handleShutdown = async (signal) => {
        console.log(`Received ${signal}. Shutting down gracefully...`);
        server.close(async () => {
            await database_1.prisma.$disconnect();
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
