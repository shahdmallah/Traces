-- Migration: v3_bookings.sql
-- Description: Add booking-related database functions and triggers

-- Function to increment trip participants count
CREATE OR REPLACE FUNCTION increment_trip_participants(trip_id UUID)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE trips
  SET current_participants = current_participants + 1,
      updated_at = NOW()
  WHERE id = trip_id
    AND status IN ('active', 'completed')
    AND current_participants < max_participants;
END;
$$;

-- Function to decrement trip participants count
CREATE OR REPLACE FUNCTION decrement_trip_participants(trip_id UUID)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE trips
  SET current_participants = GREATEST(0, current_participants - 1),
      updated_at = NOW()
  WHERE id = trip_id
    AND status IN ('active', 'completed');
END;
$$;

-- Function to create booking with transaction (prevents race conditions)
CREATE OR REPLACE FUNCTION create_booking_transaction(
  p_traveler_id UUID,
  p_trip_id UUID,
  p_participant_count INTEGER,
  p_special_requests TEXT DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_booking_id UUID;
  v_trip_status TEXT;
  v_max_participants INTEGER;
  v_current_participants INTEGER;
  v_available_spots INTEGER;
BEGIN
  -- Lock the trip row to prevent concurrent bookings
  SELECT status, max_participants, current_participants
  INTO v_trip_status, v_max_participants, v_current_participants
  FROM trips
  WHERE id = p_trip_id
  FOR UPDATE;

  -- Check if trip exists and is bookable
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Trip not found';
  END IF;

  IF v_trip_status NOT IN ('active', 'completed') THEN
    RAISE EXCEPTION 'Trip is not available for booking';
  END IF;

  -- Calculate available spots
  v_available_spots := v_max_participants - v_current_participants;

  -- Check if there are enough spots
  IF v_available_spots < p_participant_count THEN
    RAISE EXCEPTION 'Not enough available spots. Available: %, Requested: %', v_available_spots, p_participant_count;
  END IF;

  -- Create the booking
  INSERT INTO bookings (
    traveler_id,
    trip_id,
    participant_count,
    special_requests,
    status,
    created_at,
    updated_at
  ) VALUES (
    p_traveler_id,
    p_trip_id,
    p_participant_count,
    p_special_requests,
    'pending',
    NOW(),
    NOW()
  ) RETURNING id INTO v_booking_id;

  -- Update trip participants count
  UPDATE trips
  SET current_participants = current_participants + p_participant_count,
      updated_at = NOW()
  WHERE id = p_trip_id;

  RETURN v_booking_id;
END;
$$;