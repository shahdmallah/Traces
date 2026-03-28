import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const { user_id, title, body, type, metadata } = await req.json()

  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  )

  // Insert into notifications inbox
  await supabase.from('notifications').insert({
    user_id,
    type,
    title,
    body,
    metadata: metadata ?? {},
  })

  // TODO: send push via FCM using push_tokens table

  return new Response(JSON.stringify({ ok: true }), {
    headers: { 'Content-Type': 'application/json' },
  })
})
