-- ============================================
-- DATA SEED TAMBAHAN: Produk & Ulasan
-- ============================================
-- Menambahkan:
--   3 user dummy (untuk memberi ulasan)
--   6 produk baru dengan variasi stok
--   Ulasan dari berbagai user untuk produk baru & lama
-- ============================================

-- ============================================
-- STEP 1: Buat 3 user tambahan
-- ============================================
-- Hapus user lama jika ada (agar bisa re-run)
DELETE FROM auth.users WHERE email IN ('rina@example.com', 'dian@example.com', 'adi@example.com');

-- User: Rina Wijaya
DO $$
DECLARE
  uid UUID := gen_random_uuid();
BEGIN
  INSERT INTO auth.users (
    id, instance_id, aud, role, email, encrypted_password,
    email_confirmed_at, raw_app_meta_data, raw_user_meta_data,
    created_at, updated_at, confirmation_token, recovery_token
  ) VALUES (
    uid,
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'rina@example.com',
    crypt('rina123', gen_salt('bf')),
    now(),
    '{"provider": "email", "providers": ["email"]}'::jsonb,
    '{"full_name": "Rina Wijaya"}'::jsonb,
    now(), now(), '', ''
  );

  INSERT INTO auth.identities (
    id, user_id, identity_data, provider, provider_id,
    last_sign_in_at, created_at, updated_at
  ) VALUES (
    uid, uid,
    json_build_object('sub', uid::text, 'email', 'rina@example.com')::jsonb,
    'email', uid::text, now(), now(), now()
  );

  UPDATE public.profiles SET
    full_name = 'Rina Wijaya',
    phone = '081200000003'
  WHERE id = uid;
END $$;

-- User: Dian Permata
DO $$
DECLARE
  uid UUID := gen_random_uuid();
BEGIN
  INSERT INTO auth.users (
    id, instance_id, aud, role, email, encrypted_password,
    email_confirmed_at, raw_app_meta_data, raw_user_meta_data,
    created_at, updated_at, confirmation_token, recovery_token
  ) VALUES (
    uid,
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'dian@example.com',
    crypt('dian123', gen_salt('bf')),
    now(),
    '{"provider": "email", "providers": ["email"]}'::jsonb,
    '{"full_name": "Dian Permata"}'::jsonb,
    now(), now(), '', ''
  );

  INSERT INTO auth.identities (
    id, user_id, identity_data, provider, provider_id,
    last_sign_in_at, created_at, updated_at
  ) VALUES (
    uid, uid,
    json_build_object('sub', uid::text, 'email', 'dian@example.com')::jsonb,
    'email', uid::text, now(), now(), now()
  );

  UPDATE public.profiles SET
    full_name = 'Dian Permata',
    phone = '081200000004'
  WHERE id = uid;
END $$;

-- User: Adi Pratama
DO $$
DECLARE
  uid UUID := gen_random_uuid();
BEGIN
  INSERT INTO auth.users (
    id, instance_id, aud, role, email, encrypted_password,
    email_confirmed_at, raw_app_meta_data, raw_user_meta_data,
    created_at, updated_at, confirmation_token, recovery_token
  ) VALUES (
    uid,
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'adi@example.com',
    crypt('adi123', gen_salt('bf')),
    now(),
    '{"provider": "email", "providers": ["email"]}'::jsonb,
    '{"full_name": "Adi Pratama"}'::jsonb,
    now(), now(), '', ''
  );

  INSERT INTO auth.identities (
    id, user_id, identity_data, provider, provider_id,
    last_sign_in_at, created_at, updated_at
  ) VALUES (
    uid, uid,
    json_build_object('sub', uid::text, 'email', 'adi@example.com')::jsonb,
    'email', uid::text, now(), now(), now()
  );

  UPDATE public.profiles SET
    full_name = 'Adi Pratama',
    phone = '081200000005'
  WHERE id = uid;
END $$;


-- ============================================
-- STEP 2: Tambah 6 produk baru (variasi stok)
-- ============================================

-- Produk 1: Elektronik — stok 0 (habis)
INSERT INTO products (name, slug, description, price, stock, category_id, image_url) VALUES
(
  'Smartwatch FIT Pro Series 5',
  'smartwatch-fit-pro-5',
  'Smartwatch dengan monitor detak jantung, SpO2, GPS, layar AMOLED 1.4 inci. Tahan air IP68. Baterai tahan 14 hari.',
  1250000.00,
  0,
  (SELECT id FROM categories WHERE slug = 'elektronik'),
  'https://picsum.photos/seed/smartwatch-fit/400/300'
);

-- Produk 2: Fashion Pria — stok 3 (hampir habis)
INSERT INTO products (name, slug, description, price, stock, category_id, image_url) VALUES
(
  'Jaket Denim Pria Vintage',
  'jaket-denim-pria-vintage',
  'Jaket denim pria model vintage dengan bahan jeans tebal dan kancing tembaga. Cocok untuk gaya casual sehari-hari.',
  285000.00,
  3,
  (SELECT id FROM categories WHERE slug = 'fashion-pria'),
  'https://picsum.photos/seed/jaket-denim/400/300'
);

-- Produk 3: Fashion Wanita — stok 7 (terbatas)
INSERT INTO products (name, slug, description, price, stock, category_id, image_url) VALUES
(
  'Blouse Wanita Floral Lengan Panjang',
  'blouse-wanita-floral-lengan-panjang',
  'Blouse wanita motif floral dengan bahan sifon lembut dan lengan panjang. Nyaman dipakai untuk ke kantor maupun acara santai.',
  139000.00,
  7,
  (SELECT id FROM categories WHERE slug = 'fashion-wanita'),
  'https://picsum.photos/seed/blouse-floral/400/300'
);

-- Produk 4: Makanan & Minuman — stok 10 (sedang)
INSERT INTO products (name, slug, description, price, stock, category_id, image_url) VALUES
(
  'Granola Bar Oatmeal Madu 200g',
  'granola-bar-oatmeal-madu-200g',
  'Granola bar oatmeal dengan madu asli dan kacang almond. Camilan sehat tinggi serat, rendah gula. Kemasan 200g isi 10 bar.',
  45000.00,
  10,
  (SELECT id FROM categories WHERE slug = 'makanan-minuman'),
  'https://picsum.photos/seed/granola-bar/400/300'
);

-- Produk 5: Kesehatan & Kecantikan — stok 25 (cukup)
INSERT INTO products (name, slug, description, price, stock, category_id, image_url) VALUES
(
  'Lipstik Matte Liquid Velvet 8ml',
  'lipstik-matte-liquid-velvet-8ml',
  'Lipstik cair matte dengan formula velvet yang ringan, transfer-proof hingga 12 jam. Tersedia dalam 6 shade warna.',
  79000.00,
  25,
  (SELECT id FROM categories WHERE slug = 'kesehatan-kecantikan'),
  'https://picsum.photos/seed/lipstik-matte/400/300'
);

-- Produk 6: Rumah Tangga — stok 0 (habis)
INSERT INTO products (name, slug, description, price, stock, category_id, image_url) VALUES
(
  'Sapu Set Magic Clean 3in1',
  'sapu-set-magic-clean-3in1',
  'Set sapu 3in1: sapu lantai, sapu sikat, dan pengki. Bahan plastik ABS kokoh dengan gagang ergonomis.',
  65000.00,
  0,
  (SELECT id FROM categories WHERE slug = 'rumah-tangga'),
  'https://picsum.photos/seed/sapu-magic/400/300'
);


-- ============================================
-- STEP 3: Tambah ulasan dari berbagai user
-- ============================================
-- Gunakan ON CONFLICT DO NOTHING agar aman dijalankan ulang

-- Ulasan untuk produk baru
-- Smartwatch FIT Pro (stok 0)
INSERT INTO reviews (product_id, user_id, rating, comment, created_at)
SELECT
  (SELECT id FROM products WHERE slug = 'smartwatch-fit-pro-5'),
  (SELECT id FROM auth.users WHERE email = 'rina@example.com'),
  5,
  'Smartwatchnya keren banget! Fitur lengkap, baterai tahan lama. Sayang stoknya habis terus.',
  now() - interval '7 days'
WHERE EXISTS (SELECT 1 FROM products WHERE slug = 'smartwatch-fit-pro-5')
ON CONFLICT (product_id, user_id) DO NOTHING;

INSERT INTO reviews (product_id, user_id, rating, comment, created_at)
SELECT
  (SELECT id FROM products WHERE slug = 'smartwatch-fit-pro-5'),
  (SELECT id FROM auth.users WHERE email = 'dian@example.com'),
  4,
  'Desain bagus, ringan dipakai. Layarnya cerah meski di luar ruangan. Harga sesuai kualitas.',
  now() - interval '6 days'
WHERE EXISTS (SELECT 1 FROM products WHERE slug = 'smartwatch-fit-pro-5')
ON CONFLICT (product_id, user_id) DO NOTHING;

-- Jaket Denim Pria (stok 3)
INSERT INTO reviews (product_id, user_id, rating, comment, created_at)
SELECT
  (SELECT id FROM products WHERE slug = 'jaket-denim-pria-vintage'),
  (SELECT id FROM auth.users WHERE email = 'adi@example.com'),
  5,
  'Jahitan rapi, bahan tebal dan nyaman. Ukuran sesuai size chart. Recommended!',
  now() - interval '5 days'
WHERE EXISTS (SELECT 1 FROM products WHERE slug = 'jaket-denim-pria-vintage')
ON CONFLICT (product_id, user_id) DO NOTHING;

INSERT INTO reviews (product_id, user_id, rating, comment, created_at)
SELECT
  (SELECT id FROM products WHERE slug = 'jaket-denim-pria-vintage'),
  (SELECT id FROM auth.users WHERE email = 'customer@example.com'),
  4,
  'Bahan oke, model klasik. Cuma agak kebesaran sedikit, tapi masih oke.',
  now() - interval '4 days'
WHERE EXISTS (SELECT 1 FROM products WHERE slug = 'jaket-denim-pria-vintage')
ON CONFLICT (product_id, user_id) DO NOTHING;

-- Blouse Wanita Floral (stok 7)
INSERT INTO reviews (product_id, user_id, rating, comment, created_at)
SELECT
  (SELECT id FROM products WHERE slug = 'blouse-wanita-floral-lengan-panjang'),
  (SELECT id FROM auth.users WHERE email = 'rina@example.com'),
  5,
  'Motifnya cantik, bahannya adem. Cocok dipakai ke acara formal maupun santai.',
  now() - interval '3 days'
WHERE EXISTS (SELECT 1 FROM products WHERE slug = 'blouse-wanita-floral-lengan-panjang')
ON CONFLICT (product_id, user_id) DO NOTHING;

INSERT INTO reviews (product_id, user_id, rating, comment, created_at)
SELECT
  (SELECT id FROM products WHERE slug = 'blouse-wanita-floral-lengan-panjang'),
  (SELECT id FROM auth.users WHERE email = 'dian@example.com'),
  3,
  'Modelnya bagus tapi warnanya agak berbeda dari foto. Tapi overall masih okelah.',
  now() - interval '2 days'
WHERE EXISTS (SELECT 1 FROM products WHERE slug = 'blouse-wanita-floral-lengan-panjang')
ON CONFLICT (product_id, user_id) DO NOTHING;

-- Granola Bar (stok 10)
INSERT INTO reviews (product_id, user_id, rating, comment, created_at)
SELECT
  (SELECT id FROM products WHERE slug = 'granola-bar-oatmeal-madu-200g'),
  (SELECT id FROM auth.users WHERE email = 'adi@example.com'),
  4,
  'Enak, manisnya pas. Cocok buat teman diet atau cemilan sore. Pengiriman cepat.',
  now() - interval '1 day'
WHERE EXISTS (SELECT 1 FROM products WHERE slug = 'granola-bar-oatmeal-madu-200g')
ON CONFLICT (product_id, user_id) DO NOTHING;

-- Lipstik Matte (stok 25)
INSERT INTO reviews (product_id, user_id, rating, comment, created_at)
SELECT
  (SELECT id FROM products WHERE slug = 'lipstik-matte-liquid-velvet-8ml'),
  (SELECT id FROM auth.users WHERE email = 'rina@example.com'),
  4,
  'Teksturnya ringan, tidak bikin kering. Tahan lama meski pakai masker. Warnanya pigmented banget!',
  now() - interval '12 hours'
WHERE EXISTS (SELECT 1 FROM products WHERE slug = 'lipstik-matte-liquid-velvet-8ml')
ON CONFLICT (product_id, user_id) DO NOTHING;

INSERT INTO reviews (product_id, user_id, rating, comment, created_at)
SELECT
  (SELECT id FROM products WHERE slug = 'lipstik-matte-liquid-velvet-8ml'),
  (SELECT id FROM auth.users WHERE email = 'dian@example.com'),
  5,
  'Suka banget sama warnanya! Matte tapi tetap nyaman di bibir. Sudah repeat order.',
  now() - interval '6 hours'
WHERE EXISTS (SELECT 1 FROM products WHERE slug = 'lipstik-matte-liquid-velvet-8ml')
ON CONFLICT (product_id, user_id) DO NOTHING;

-- Ulasan untuk produk lama (agar rating > 0 terlihat di halaman produk)
-- Laptop ASUS VivoBook
INSERT INTO reviews (product_id, user_id, rating, comment, created_at)
SELECT
  (SELECT id FROM products WHERE slug = 'laptop-asus-vivobook-14'),
  (SELECT id FROM auth.users WHERE email = 'rina@example.com'),
  5,
  'Laptop kencang buat coding dan ngedit ringan. Baterai cukup awet. Recommended buat mahasiswa!',
  now() - interval '15 days'
WHERE EXISTS (SELECT 1 FROM products WHERE slug = 'laptop-asus-vivobook-14')
ON CONFLICT (product_id, user_id) DO NOTHING;

INSERT INTO reviews (product_id, user_id, rating, comment, created_at)
SELECT
  (SELECT id FROM products WHERE slug = 'laptop-asus-vivobook-14'),
  (SELECT id FROM auth.users WHERE email = 'adi@example.com'),
  4,
  'Performa oke untuk harga segini. Cuma agak berat dibawa kemana-mana.',
  now() - interval '10 days'
WHERE EXISTS (SELECT 1 FROM products WHERE slug = 'laptop-asus-vivobook-14')
ON CONFLICT (product_id, user_id) DO NOTHING;

INSERT INTO reviews (product_id, user_id, rating, comment, created_at)
SELECT
  (SELECT id FROM products WHERE slug = 'laptop-asus-vivobook-14'),
  (SELECT id FROM auth.users WHERE email = 'customer@example.com'),
  5,
  'Sudah 3 bulan pemakaian, masih mulus. Layar bagus, keyboard nyaman buat ngetik.',
  now() - interval '5 days'
WHERE EXISTS (SELECT 1 FROM products WHERE slug = 'laptop-asus-vivobook-14')
ON CONFLICT (product_id, user_id) DO NOTHING;

-- Samsung Galaxy A54
INSERT INTO reviews (product_id, user_id, rating, comment, created_at)
SELECT
  (SELECT id FROM products WHERE slug = 'samsung-galaxy-a54-5g'),
  (SELECT id FROM auth.users WHERE email = 'dian@example.com'),
  4,
  'Kamera bagus, hasil foto siang hari jernih. Baterai awet seharian.',
  now() - interval '8 days'
WHERE EXISTS (SELECT 1 FROM products WHERE slug = 'samsung-galaxy-a54-5g')
ON CONFLICT (product_id, user_id) DO NOTHING;

INSERT INTO reviews (product_id, user_id, rating, comment, created_at)
SELECT
  (SELECT id FROM products WHERE slug = 'samsung-galaxy-a54-5g'),
  (SELECT id FROM auth.users WHERE email = 'customer@example.com'),
  4,
  'HP oke, lancar buat main game ringan. Cuma agak panas kalau dipake sambil ngecas.',
  now() - interval '3 days'
WHERE EXISTS (SELECT 1 FROM products WHERE slug = 'samsung-galaxy-a54-5g')
ON CONFLICT (product_id, user_id) DO NOTHING;

-- TWS Earbuds Pro
INSERT INTO reviews (product_id, user_id, rating, comment, created_at)
SELECT
  (SELECT id FROM products WHERE slug = 'tws-earbuds-pro-bluetooth'),
  (SELECT id FROM auth.users WHERE email = 'adi@example.com'),
  5,
  'Suara jernih, ANC lumayan buat harga segini. Koneksi stabil. Battery case tahan lama.',
  now() - interval '4 days'
WHERE EXISTS (SELECT 1 FROM products WHERE slug = 'tws-earbuds-pro-bluetooth')
ON CONFLICT (product_id, user_id) DO NOTHING;

-- Kopi Arabica Gayo
INSERT INTO reviews (product_id, user_id, rating, comment, created_at)
SELECT
  (SELECT id FROM products WHERE slug = 'kopi-arabica-gayo-premium-250g'),
  (SELECT id FROM auth.users WHERE email = 'rina@example.com'),
  5,
  'Aromanya wangi, rasanya smooth dengan after taste manis. Recommended buat pecinta kopi!',
  now() - interval '9 days'
WHERE EXISTS (SELECT 1 FROM products WHERE slug = 'kopi-arabica-gayo-premium-250g')
ON CONFLICT (product_id, user_id) DO NOTHING;

INSERT INTO reviews (product_id, user_id, rating, comment, created_at)
SELECT
  (SELECT id FROM products WHERE slug = 'kopi-arabica-gayo-premium-250g'),
  (SELECT id FROM auth.users WHERE email = 'adi@example.com'),
  4,
  'Rasa enak, pengiriman cepet. Roastingnya pas buat saya yang suka medium.',
  now() - interval '6 days'
WHERE EXISTS (SELECT 1 FROM products WHERE slug = 'kopi-arabica-gayo-premium-250g')
ON CONFLICT (product_id, user_id) DO NOTHING;

-- Serum Vitamin C
INSERT INTO reviews (product_id, user_id, rating, comment, created_at)
SELECT
  (SELECT id FROM products WHERE slug = 'serum-vitamin-c-20-brightening'),
  (SELECT id FROM auth.users WHERE email = 'dian@example.com'),
  5,
  'Pemakaian 2 minggu, kulit terasa lebih cerah dan lembab. Teksturnya ringan, cepat meresap.',
  now() - interval '11 days'
WHERE EXISTS (SELECT 1 FROM products WHERE slug = 'serum-vitamin-c-20-brightening')
ON CONFLICT (product_id, user_id) DO NOTHING;

INSERT INTO reviews (product_id, user_id, rating, comment, created_at)
SELECT
  (SELECT id FROM products WHERE slug = 'serum-vitamin-c-20-brightening'),
  (SELECT id FROM auth.users WHERE email = 'rina@example.com'),
  4,
  'Bagus, tapi mungkin kurang cocok buat kulit sensitif. Awalnya agak perih tapi hilang sendiri.',
  now() - interval '7 days'
WHERE EXISTS (SELECT 1 FROM products WHERE slug = 'serum-vitamin-c-20-brightening')
ON CONFLICT (product_id, user_id) DO NOTHING;

-- Panci Set Anti Lengket
INSERT INTO reviews (product_id, user_id, rating, comment, created_at)
SELECT
  (SELECT id FROM products WHERE slug = 'panci-set-anti-lengket-5-pcs'),
  (SELECT id FROM auth.users WHERE email = 'customer@example.com'),
  5,
  'Kualitas bagus, benar anti lengket. Tutup kacanya tebal. Cocok untuk kebutuhan masak sehari-hari.',
  now() - interval '12 days'
WHERE EXISTS (SELECT 1 FROM products WHERE slug = 'panci-set-anti-lengket-5-pcs')
ON CONFLICT (product_id, user_id) DO NOTHING;

-- Rak Sepatu Lipat
INSERT INTO reviews (product_id, user_id, rating, comment, created_at)
SELECT
  (SELECT id FROM products WHERE slug = 'rak-sepatu-lipat-4-tingkat'),
  (SELECT id FROM auth.users WHERE email = 'adi@example.com'),
  3,
  'Raknya cukup muat, tapi bahannya agak tipis. Pas untuk harga segini sih.',
  now() - interval '2 days'
WHERE EXISTS (SELECT 1 FROM products WHERE slug = 'rak-sepatu-lipat-4-tingkat')
ON CONFLICT (product_id, user_id) DO NOTHING;

-- Lampu LED Meja
INSERT INTO reviews (product_id, user_id, rating, comment, created_at)
SELECT
  (SELECT id FROM products WHERE slug = 'lampu-led-meja-belajar-rechargeable'),
  (SELECT id FROM auth.users WHERE email = 'dian@example.com'),
  4,
  'Cahaya bisa diatur, baterai tahan lama. Cocok buat belajar di malam hari.',
  now() - interval '1 day'
WHERE EXISTS (SELECT 1 FROM products WHERE slug = 'lampu-led-meja-belajar-rechargeable')
ON CONFLICT (product_id, user_id) DO NOTHING;


-- ============================================
-- VERIFIKASI
-- ============================================
SELECT
  p.name AS produk,
  p.stock AS stok,
  COUNT(r.id) AS total_ulasan,
  COALESCE(ROUND(AVG(r.rating)::numeric, 1), 0) AS rata_rata_rating
FROM products p
LEFT JOIN reviews r ON r.product_id = p.id
WHERE p.name IN (
  'Smartwatch FIT Pro Series 5',
  'Jaket Denim Pria Vintage',
  'Blouse Wanita Floral Lengan Panjang',
  'Granola Bar Oatmeal Madu 200g',
  'Lipstik Matte Liquid Velvet 8ml',
  'Sapu Set Magic Clean 3in1',
  'Laptop ASUS VivoBook 14',
  'Samsung Galaxy A54 5G',
  'TWS Earbuds Pro Bluetooth 5.3',
  'Kopi Arabica Gayo Premium 250g',
  'Serum Vitamin C 20% Brightening',
  'Panci Set Anti Lengket 5 Pcs',
  'Rak Sepatu Lipat 4 Tingkat',
  'Lampu LED Meja Belajar Rechargeable'
)
GROUP BY p.id, p.name, p.stock
ORDER BY p.name;
