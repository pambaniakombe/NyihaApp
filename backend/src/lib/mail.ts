import nodemailer from "nodemailer";

const from = process.env.MAIL_FROM ?? "Nyiha Society <noreply@nyiha.local>";

function createTransport() {
  const url = process.env.SMTP_URL;
  if (url) return nodemailer.createTransport(url);
  const host = process.env.SMTP_HOST;
  const port = Number(process.env.SMTP_PORT ?? "587");
  const user = process.env.SMTP_USER;
  const pass = process.env.SMTP_PASS;
  if (host && user && pass) {
    return nodemailer.createTransport({
      host,
      port,
      secure: port === 465,
      auth: { user, pass },
    });
  }
  return null;
}

export async function sendPasswordResetEmail(to: string, resetUrl: string): Promise<{ ok: boolean; devFallback?: string }> {
  const transporter = createTransport();
  const subject = "Nyiha — badilisha nenosiri";
  const text = `Tembelea kiungo hiki kubadili nenosiri lako (litazama kwa saa 1 tu):\n\n${resetUrl}\n\n`;
  const html = `<p>Tumia kiungo hiki kubadili nenosiri (saa 1):</p><p><a href="${resetUrl}">${resetUrl}</a></p>`;

  if (!transporter) {
    const msg = `[mail] SMTP not configured. Reset link for ${to}:\n${resetUrl}`;
    console.warn(msg);
    return { ok: true, devFallback: resetUrl };
  }

  await transporter.sendMail({ from, to, subject, text, html });
  return { ok: true };
}

export async function sendNewPasswordEmail(
  to: string,
  newPassword: string,
): Promise<{ ok: boolean; devFallback?: string }> {
  const transporter = createTransport();
  const subject = "Nyiha — nenosiri jipya";
  const text =
    `Tumetengeneza nenosiri jipya kwa akaunti yako.\n\n` +
    `Nenosiri jipya: ${newPassword}\n\n` +
    `Tafadhali ingia kisha libadilishe mara moja ndani ya programu.`;
  const html =
    `<p>Tumetengeneza nenosiri jipya kwa akaunti yako.</p>` +
    `<p><strong>Nenosiri jipya:</strong> <code>${newPassword}</code></p>` +
    `<p>Tafadhali ingia kisha libadilishe mara moja ndani ya programu.</p>`;

  if (!transporter) {
    const msg = `[mail] SMTP not configured. New password for ${to}: ${newPassword}`;
    console.warn(msg);
    return { ok: true, devFallback: newPassword };
  }

  await transporter.sendMail({ from, to, subject, text, html });
  return { ok: true };
}
