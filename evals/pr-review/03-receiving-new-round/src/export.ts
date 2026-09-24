type Account = { id: string; finalized: boolean }

export const exportAccount = async (
  id: string,
  db: { find(id: string): Promise<Account | null>; finalize(id: string): Promise<Account> },
  publish: (account: Account) => Promise<void>,
) => {
  const existing = await db.find(id)
  const account = existing?.finalized ? existing : await db.finalize(id)
  await publish(account)
  return account
}
