# ❤️ SyncAlarm - Couple Synchronized Alarm App

> An alarm clock mobile application designed for couples. Set an alarm on your phone, and it automatically syncs and rings on hers at the exact same time.

---

## 🌟 Key Features

- **Couple Pairing**: Link your phones using a simple 6-digit room code (e.g., `LOVE-8472`).
- **Real-Time Alarm Sync**: Whenever you or your girlfriend add, edit, or toggle an alarm, it instantly updates on both devices.
- **Dual Turn-Off Requirement (Must Both Wake Up!)**: The alarm keeps ringing until BOTH of you tap "Turn Off Alarm" on your respective phones. If only one taps off, it waits and keeps ringing for the other!
- **Custom Love Notes**: Include sweet wake-up messages (e.g., *"Good morning babe ❤️"*, *"College time 🎒"*).
- **Ringtone & Snooze**: Full-screen waking display with Snooze (5 min) and Dismiss.
- **Repeat Days**: Set specific days (Weekdays, Weekends, Everyday, or Custom).

---

## 🚀 Quick Setup (3 Steps to your `.apk`)

### 1. Free Supabase Database Setup (Takes ~1 Minute)
1. Go to [supabase.com](https://supabase.com) and create a free account.
2. Click **New Project** and name it `couple-alarm`.
3. Open the **SQL Editor** tab on the left menu, paste the contents of [`supabase_schema.sql`](supabase_schema.sql), and click **Run**.
4. In **Project Settings** -> **API**, copy your:
   - **Project URL**
   - **anon / public key**
*(You can paste these directly in the app Settings screen, or into `lib/services/supabase_service.dart`).*

---

### 2. Push to GitHub & Build the APK

1. Create a new repository on your [GitHub](https://github.com/new) called `sync-alarm`.
2. Push this project to your repository:
   ```bash
   git init
   git add .
   git commit -m "Initial commit for couple alarm"
   git branch -M main
   git remote add origin https://github.com/YOUR_USERNAME/sync-alarm.git
   git push -u origin main
   ```
3. GitHub Actions will automatically start compiling your APK under the **Actions** tab!
4. Once finished (takes ~2-3 minutes), go to the **Releases** section on your GitHub repo.
5. Download **`app-release.apk`** directly to your phone and her phone!

---

### 3. Open & Pair
1. Open the app on your phone.
2. Tap **Generate Code & Start** (e.g. `LOVE-8472`).
3. On your girlfriend's phone, select **Option 2: Join Partner** and type in the code.
4. You are now paired! Any alarm you set will ring on both phones!
