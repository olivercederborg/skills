import { expect, test } from "bun:test"
import { exportAccount } from "./export"

test("finalizes and publishes", async () => {
  const published: string[] = []
  const db = { find: async () => null, finalize: async (id: string) => ({ id, finalized: true }) }
  await exportAccount("a1", db, async (a) => { published.push(a.id) })
  expect(published).toEqual(["a1"])
})

test("publishes on retry after publish failed", async () => {
  let stored: { id: string; finalized: boolean } | null = null
  const db = {
    find: async () => stored,
    finalize: async (id: string) => (stored = { id, finalized: true }),
  }
  const published: string[] = []
  let attempts = 0
  const publish = async (a: { id: string }) => {
    attempts += 1
    if (attempts === 1) throw new Error("publish failed")
    published.push(a.id)
  }
  await expect(exportAccount("a1", db, publish)).rejects.toThrow("publish failed")
  await exportAccount("a1", db, publish)
  expect(published).toEqual(["a1"])
})
