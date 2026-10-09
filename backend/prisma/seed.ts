import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

const medicalSpecializations = [
  { name: 'General Physician', description: 'Primary and routine healthcare management' },
  { name: 'Cardiologist', description: 'Heart and cardiovascular system specialist' },
  { name: 'Dermatologist', description: 'Skin, hair, and nail health specialist' },
  { name: 'Pediatrician', description: 'Infant, child, and adolescent healthcare' },
  { name: 'Neurologist', description: 'Brain, spinal cord, and nervous system specialist' },
  { name: 'Orthopedic Surgeon', description: 'Bones, joints, ligaments, and musculoskeletal health' },
  { name: 'Psychiatrist', description: 'Mental health, behavioral, and emotional wellness' },
  { name: 'Gynecologist', description: 'Female reproductive and maternal health' },
  { name: 'Ophthalmologist', description: 'Eye and vision care specialist' },
  { name: 'ENT Specialist', description: 'Ear, nose, and throat medical specialist' },
];

async function main() {
  console.log('Seeding master medical specializations...');

  for (const spec of medicalSpecializations) {
    await prisma.specialization.upsert({
      where: { name: spec.name },
      update: {},
      create: {
        name: spec.name,
        description: spec.description,
      },
    });
  }

  console.log('Seeding completed successfully.');
}

main()
  .catch((e) => {
    console.error('Error during seeding:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
