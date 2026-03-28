import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const { traveler_id, trip_id } = await req.json()

  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  )

  const [{ data: traveler }, { data: trip }] = await Promise.all([
    supabase.from('traveler_profiles').select('*').eq('user_id', traveler_id).single(),
    supabase.from('trips').select('*').eq('id', trip_id).single(),
  ])

  // Simple scoring — extend with real AI logic
  const breakdown = {
    budget: scoreBudget(traveler, trip),
    style: scoreStyle(traveler, trip),
    dates: 80, // placeholder
  }
  const score = Object.values(breakdown).reduce((a, b) => a + b, 0) / Object.keys(breakdown).length

  await supabase.from('match_scores').upsert({
    traveler_id,
    trip_id,
    score,
    score_breakdown: breakdown,
    computed_at: new Date().toISOString(),
  })

  return new Response(JSON.stringify({ score }), {
    headers: { 'Content-Type': 'application/json' },
  })
})

function scoreBudget(traveler: any, trip: any): number {
  const prefs = traveler?.travel_preferences?.budgets ?? []
  if (!prefs.length) return 70
  // TODO: map trip price to budget tier and score
  return 75
}

function scoreStyle(traveler: any, trip: any): number {
  const styles = traveler?.travel_styles ?? []
  const tripTags = trip?.smart_match_config?.styles ?? []
  const overlap = styles.filter((s: string) => tripTags.includes(s)).length
  return Math.min(100, 50 + overlap * 15)
}
