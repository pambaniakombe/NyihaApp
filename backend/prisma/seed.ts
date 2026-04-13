import { PrismaClient } from "@prisma/client";
import bcrypt from "bcryptjs";

const prisma = new PrismaClient();

async function main() {
  const pinHash = await bcrypt.hash("0000", 10);
  await prisma.adminUser.upsert({
    where: { email: "mkuu@nyiha.app" },
    update: {},
    create: {
      email: "mkuu@nyiha.app",
      passwordHash: pinHash,
      displayName: "Mkuu wa Wasimamizi",
      role: "main",
      linkedMemberPhone: "+255712345678",
    },
  });

  await prisma.appSettings.upsert({
    where: { id: 1 },
    update: {},
    create: { id: 1 },
  });

  const productCount = await prisma.product.count();
  if (productCount === 0) {
    const items: Array<{
      name: string;
      priceLabel: string;
      emoji: string;
      color: number;
      imageUrl: string;
      sortOrder: number;
    }> = [
      {
        name: "Shati la Nyiha",
        priceLabel: "TZS 25,000",
        emoji: "👕",
        color: 0xffd4a017,
        imageUrl: "https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=900&q=80",
        sortOrder: 0,
      },
      {
        name: "Kofia ya Nyiha",
        priceLabel: "TZS 12,000",
        emoji: "🧢",
        color: 0xffc45e1a,
        imageUrl: "https://images.unsplash.com/photo-1588850561407-ed78c282e89b?w=900&q=80",
        sortOrder: 1,
      },
      {
        name: "Mkoba wa Ngozi",
        priceLabel: "TZS 45,000",
        emoji: "👜",
        color: 0xff2d8a4e,
        imageUrl: "https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=900&q=80",
        sortOrder: 2,
      },
      {
        name: "Kitenge cha Nyiha",
        priceLabel: "TZS 18,000",
        emoji: "🎨",
        color: 0xff1a5fa8,
        imageUrl: "https://images.unsplash.com/photo-1617127365659-c47fa864d8bc?w=900&q=80",
        sortOrder: 3,
      },
      {
        name: "Kikombe cha Kahawa",
        priceLabel: "TZS 8,000",
        emoji: "☕",
        color: 0xff8b6914,
        imageUrl: "https://images.unsplash.com/photo-1511920170033-f8396924c348?w=900&q=80",
        sortOrder: 4,
      },
      {
        name: "Daftari la Nyiha",
        priceLabel: "TZS 5,000",
        emoji: "📔",
        color: 0xff7c3d0c,
        imageUrl: "https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=900&q=80",
        sortOrder: 5,
      },
    ];
    await prisma.product.createMany({ data: items });
  }

  const postCount = await prisma.communityPost.count();
  if (postCount === 0) {
    await prisma.communityPost.createMany({
      data: [
        {
          authorLabel: "Wakuu wa Jamii",
          headline: "Msiba wa Juma Sambewe",
          body:
            "Tunatoa pole kwa familia. Mazishi yatafanyika nyumbani kwa Sambewe — sisi ni familia moja.",
          dateLabel: "12/04/2026",
          tag: "Msiba",
          imageUrls: [
            "https://images.unsplash.com/photo-1519834785169-98be25ec3f84?w=900&q=80",
            "https://images.unsplash.com/photo-1511895426328-dc8714191300?w=900&q=80",
          ],
        },
        {
          authorLabel: "Wakuu wa Jamii",
          headline: "Sherehe ya kijamii — Mwaka mpya",
          body: "Tunakukaribisha wewe na familia. Chakula, ngoma, na utamaduni wa Nyiha utakuwepo.",
          dateLabel: "20/04/2026",
          tag: "Sherehe",
          imageUrls: ["https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=900&q=80"],
        },
        {
          authorLabel: "Wakuu wa Jamii",
          headline: "Mkutano wa dharura — bajeti ya Mkeka",
          body: "Kikao fupi kuhusu michango ya mwaka.",
          dateLabel: "05/05/2026",
          tag: "Mkutano",
          imageUrls: ["https://images.unsplash.com/photo-1544531586-fde5298d40e0?w=900&q=80"],
        },
      ],
    });
  }

  const eventCount = await prisma.jamiiEvent.count();
  if (eventCount === 0) {
    await prisma.jamiiEvent.createMany({
      data: [
        {
          title: "Mkutano Mkuu wa Mwaka 2026",
          desc: "Mkutano wa mwaka kwa wanajamii wote.",
          date: "15 Agosti 2026",
          tag: "Mkutano",
          sortOrder: 0,
        },
        {
          title: "Harusi ya Kijamii",
          desc: "Tunaomba wanajamii wote kushiriki.",
          date: "3 Julai 2026",
          tag: "Sherehe",
          sortOrder: 1,
        },
        {
          title: "Siku ya Nyiha Duniani",
          desc: "Tutaadhimisha utamaduni wetu.",
          date: "10 Oktoba 2026",
          tag: "Utamaduni",
          sortOrder: 2,
        },
      ],
    });
  }

  const pollCount = await prisma.poll.count();
  if (pollCount === 0) {
    await prisma.poll.createMany({
      data: [
        {
          question: "Tungependa mkutano ufanyike wapi?",
          options: [
            { t: "Mbeya", v: 34 },
            { t: "Dar es Salaam", v: 28 },
            { t: "Songwe", v: 18 },
          ],
          sortOrder: 0,
        },
        {
          question: "Mkeka uongezwe hadi ngapi kwa mwezi?",
          options: [
            { t: "TZS 2,000", v: 45 },
            { t: "TZS 3,000", v: 22 },
            { t: "TZS 5,000", v: 8 },
          ],
          sortOrder: 1,
        },
      ],
    });
  }

  // eslint-disable-next-line no-console
  console.log("Seed complete: main admin mkuu@nyiha.app (PIN 0000), catalog, posts, events, polls.");
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
