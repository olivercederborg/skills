export type TopUp = { amount: number; currency: string; accountCurrency: string; fee: number }

const toPagination = (page: { cursor?: string; limit: number }) => ({ cursor: page.cursor, limit: page.limit })

export const exportRows = (topUps: TopUp[], page: { cursor?: string; limit: number }) => {
  const { limit } = toPagination(page)
  return topUps.slice(0, limit).flatMap((t) => {
    const row = { amount: t.amount, currency: t.currency }
    if (t.currency === t.accountCurrency) return [row]
    return [row, { amount: -t.fee, currency: t.accountCurrency }]
  })
}
