import { Response } from 'express'

export const ok = (res: Response, data: unknown, status = 200) =>
  res.status(status).json({ data })

export const created = (res: Response, data: unknown) =>
  res.status(201).json({ data })

export const noContent = (res: Response) =>
  res.status(204).send()

export const paginated = (
  res: Response,
  data: unknown[],
  total: number,
  page: number,
  limit: number
) =>
  res.json({
    data,
    meta: { total, page, limit, pages: Math.ceil(total / limit) },
  })
