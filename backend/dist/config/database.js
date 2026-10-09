"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.connectDatabase = exports.prisma = void 0;
const client_1 = require("@prisma/client");
const env_1 = require("./env");
exports.prisma = global.prismaGlobal ||
    new client_1.PrismaClient({
        log: env_1.env.NODE_ENV === 'development' ? ['query', 'error', 'warn'] : ['error'],
    });
if (env_1.env.NODE_ENV !== 'production') {
    global.prismaGlobal = exports.prisma;
}
const connectDatabase = async () => {
    try {
        await exports.prisma.$connect();
        console.log('PostgreSQL database connected successfully via Prisma.');
        return true;
    }
    catch (error) {
        console.error('Failed to connect to PostgreSQL database:', error);
        return false;
    }
};
exports.connectDatabase = connectDatabase;
