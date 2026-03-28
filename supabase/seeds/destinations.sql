-- Sample destinations seed
-- Extend with your own destinations

insert into destinations (name, country, region, description, is_featured) values
  ('Petra',     'Jordan', 'Ma''an Governorate',   'Ancient Nabataean city carved into rose-red rock', true),
  ('Wadi Rum',  'Jordan', 'Aqaba Governorate',    'Vast desert landscape of sandstone and valleys',   true),
  ('Jerash',    'Jordan', 'Jerash Governorate',   'One of the best preserved Roman cities',           false),
  ('Aqaba',     'Jordan', 'Aqaba Governorate',    'Red Sea coastal city, diving and beaches',         false),
  ('Dead Sea',  'Jordan', 'Balqa Governorate',    'Lowest point on earth, therapeutic salt waters',   true);
