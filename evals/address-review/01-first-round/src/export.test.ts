import { expect, test } from "bun:test"
import { exportAccount } from "./export"

test("finalizes and publishes", async () => {
  const published: string[] = []
  const db = { find: async () => null, finalize: async (id: string) => ({ id, finalized: true }) }
  await exportAccount("a1", db, async (a) => { published.push(a.id) })
  expect(published).toEqual(["a1"])
})
