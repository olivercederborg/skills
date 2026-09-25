export type TopUp = { amount: number; currency: string; accountCurrency: string; fee: number }

export const exportRows = (topUps: TopUp[]) =>
  topUps.map((t) => ({ amount: t.amount, currency: t.currency }))
