import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const { payout_id } = await req.json()

  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  )

  const { data: payout } = await supabase
    .from('payouts')
    .select('*, organizer_profiles(*)')
    .eq('id', payout_id)
    .single()

  if (!payout) {
    return new Response(JSON.stringify({ error: 'Payout not found' }), { status: 404 })
  }

  // TODO: integrate with Stripe / payment provider
  // For now, mark as processing
  await supabase
    .from('payouts')
    .update({ status: 'processing', processed_at: new Date().toISOString() })
    .eq('id', payout_id)

  return new Response(JSON.stringify({ ok: true }), {
    headers: { 'Content-Type': 'application/json' },
  })
})
