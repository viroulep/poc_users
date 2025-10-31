import Image from "next/image";
import { auth, signIn, signOut } from "@/auth"
import styles from "./page.module.css";
import { SessionProvider } from "next-auth/react";
import { createJwt } from "@/lib/backend";

function SignIn() {
  return (
    <form
      action={async () => {
        "use server"
        await signIn()
      }}
    >
      <button type="submit">Sign in</button>
    </form>
  )
}

function SignOut() {
  return (
    <form
      action={async () => {
        "use server"
        await signOut()
      }}
    >
      <button type="submit">Sign out</button>
    </form>
  )
}

async function getBackendUser(data: any) {
  if (!data.user) {
    return {};
  }
  const jwt = await createJwt(data.user);

  // FIXME: using GET for now
  const backendRes = await fetch(`http://localhost:3000/jwtlogin`, {
    method: "GET",
    headers: { Authorization: `Bearer ${jwt}` },
    cache: "no-store",
  });
  const res = await backendRes.json();
  return res;
}

export default async function Home() {

  const session = await auth();
  const backendUser = session ? await getBackendUser(session) : {};
  console.log(backendUser);

  return (
    <div className={styles.page}>
      <main className={styles.main}>
        <div className="flex flex-col rounded-md bg-gray-100">
          <div className="rounded-t-md bg-gray-200 p-4 font-bold">
            Current Session
          </div>
          <pre className="whitespace-pre-wrap break-all px-4 py-6">
            {JSON.stringify(session, null, 2)}
          </pre>
        </div>
        <div style={{display: "flex", justifyContent: "space-evenly"}}>
          <SignIn />
          <SignOut />
        </div>
        <div className="flex flex-col rounded-md bg-gray-100">
          <div className="rounded-t-md bg-gray-200 p-4 font-bold">
            Current backenduser
          </div>
          <pre className="whitespace-pre-wrap break-all px-4 py-6">
            {JSON.stringify(backendUser, null, 2)}
          </pre>
        </div>
      </main>
      <footer className={styles.footer}>
        <div>coucou</div>
      </footer>
    </div>
  );
}
