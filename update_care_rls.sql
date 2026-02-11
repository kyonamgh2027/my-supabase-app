-- 위험한 정책 삭제
   DROP POLICY IF EXISTS "Enable all access for care table" ON care;
   DROP POLICY IF EXISTS "Users can delete own care records" ON care;
   DROP POLICY IF EXISTS "Users can insert own care records" ON care;
   DROP POLICY IF EXISTS "Users can update own care records" ON care;
   DROP POLICY IF EXISTS "Users can view own care records" ON care;
   DROP POLICY IF EXISTS "관리자 전체 삭제" ON care;
   DROP POLICY IF EXISTS "관리자 전체 삽입" ON care;
   DROP POLICY IF EXISTS "관리자 전체 조회" ON care;
   DROP POLICY IF EXISTS "시설별 삭제" ON care;
   DROP POLICY IF EXISTS "시설별 삽입" ON care;

   -- 1. 관리자 전체 조회/수정/삭제 가능
   CREATE POLICY "관리자 전체 접근" ON care
   FOR ALL
   USING (
     (auth.jwt() -> 'user_metadata'::text) ->> 'facility'::text = 'all'
   );

   -- 2. 같은 기관 직원끼리 조회 가능
   CREATE POLICY "같은 기관 조회" ON care
   FOR SELECT
   USING (
     facility = ((auth.jwt() -> 'user_metadata') ->> 'facility')
   );

   -- 3. 본인 데이터 입력/수정/삭제
   CREATE POLICY "본인 데이터 입력" ON care
   FOR INSERT
   WITH CHECK (auth.uid() = user_id);

   CREATE POLICY "본인 데이터 수정" ON care
   FOR UPDATE
   USING (auth.uid() = user_id);

   CREATE POLICY "본인 데이터 삭제" ON care
   FOR DELETE
   USING (auth.uid() = user_id);

   -- RLS 활성화
   ALTER TABLE care ENABLE ROW LEVEL SECURITY;
