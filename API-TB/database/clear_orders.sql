-- ============================================
-- HAPUS SEMUA RIWAYAT PESANAN
-- Digunakan untuk membersihkan data order & order_items
-- ============================================
-- Peringatan:
--   - Operasi ini TIDAK bisa di-rollback
--   - order_items otomatis kehapus karena ON DELETE CASCADE
--   - Data user, produk, kategori, dan lainnya TIDAK terpengaruh
-- ============================================

DELETE FROM orders;
