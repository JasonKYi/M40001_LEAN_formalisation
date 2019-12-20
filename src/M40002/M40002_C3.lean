-- M40002 (Analysis I) Chapter 3. Sequences

import M40002.M40002_C2

namespace M40002

-- Defintions for convergent sequences

def converges_to (a : ℕ → ℝ) (l : ℝ) :=  ∀ ε > 0, ∃ N : ℕ, ∀ n ≥ N, abs (a n - l) < ε 
notation a ` ⇒ ` l := converges_to a l

def is_convergent (a : ℕ → ℝ) := ∃ l : ℝ, ∀ ε > 0, ∃ N : ℕ, ∀ n ≥ N, abs (a n - l) < ε 

def seq_bounded_above (a : ℕ → ℝ) := ∃ n : ℕ, ∀ m : ℕ, a m ≤ a n
def seq_bounded_below (a : ℕ → ℝ) := ∃ n : ℕ, ∀ m : ℕ, a n ≤ a m

def seq_bounded (a : ℕ → ℝ) := seq_bounded_above a ∧ seq_bounded_below a

-- Example 3.4 (1 / n → 0)
example (a : ℕ → ℝ) (ha : a = λ n : ℕ, 1 / n) : a ⇒ 0 :=
begin
    intros ε hε,
    have : ∃ N : ℕ, (1 / (N + 1) : ℝ) < ε := exists_nat_one_div_lt hε,
    cases this with N hN,
        use (N + 1),
    intros n hn,
    simp,
    have hb : 0 ≤ a n := by {rw ha, simp},
    have : abs (a n) = a n := by {exact abs_of_nonneg hb},
    rw [this, ha], dsimp,
    have hc : (1 / n : ℝ) ≤ (1 / (N + 1) : ℝ) := 
        by {apply div_le_div_of_le_left,
            {linarith},
            {have hd : 0 ≤ (N : ℝ) := nat.cast_nonneg N,
            linarith
            },
            {rw ge_from_le at hn,
            norm_cast, assumption
            },
        },
    rw le_iff_lt_or_eq at hc,
    cases hc,
        {from lt_trans hc hN},
        {rwa hc}
end

-- Example 3.5 ((n + 5) / (n + 1) → 1)
example (a : ℕ → ℝ) (ha : a = λ n : ℕ, (n + 5) / (n + 1)) : a ⇒ 1 :=
begin
    intros ε hε,
    have : ∃ N : ℕ, (4 / N : ℝ) < ε :=
        by {cases exists_nat_one_div_lt hε with M hM,
        use (4 * (M + 1)),
        suffices : 4 / (4 * (↑M + 1)) < ε,
          exact_mod_cast this,
        have : (4 : ℝ) ≠ 0 := by linarith,
        rwa (div_mul_right (↑M + 1 : ℝ) this),
        },
    cases this with N hN,
    use N, intros n hn,
    have h0 : 0 ≤ a n - 1 :=
        by {rw ha, simp,
        rw (show (5 + ↑n :ℝ) = 4 + 1 + ↑n, by linarith),
        rw [add_assoc, add_div, div_self], 
        suffices : (0 : ℝ) ≤ 4 / (1 + ↑n),
          simpa using this,
        refine le_of_lt (div_pos (by linarith) _),
        repeat {norm_cast, linarith},
        },
    rw [abs_of_nonneg h0, ha],
    suffices : (5 + ↑n) / (1 + ↑n) - 1 < ε,
        simpa using this,
    rw (show (5 + ↑n :ℝ) = 4 + 1 + ↑n, by linarith),
    rw [add_assoc, add_div, div_self], 
    {suffices : 4 / (1 + ↑n) < ε,
        simpa using this,
    have : 1 / (1 + n) ≤ 1 / N :=
        by {sorry},
    sorry,
    },
    sorry, -- Terribly sorry but I can't bring myself to complete this proof!
end

-- Limits are unique! (I gotta admit this my proof is very terrible with alot of unnecessary lines :/)
theorem unique_lim (a : ℕ → ℝ) (b c : ℝ) (hb : a ⇒ b) (hc : a ⇒ c) : b = c :=
begin
    have : ∀ (ε : ℝ), ε > 0 → (∃ (N : ℕ), ∀ (n : ℕ), n ≥ N → abs (b - c) < ε) :=
        by {intros ε hε,
        cases hb (ε / 2) (half_pos hε) with N₁ hN₁,
        cases hc (ε / 2) (half_pos hε) with N₂ hN₂,
        use max N₁ N₂,
        intros n hn,
        have : N₁ ≤ n ∧ N₂ ≤ n := 
                by {split, 
                    {apply le_trans (le_max_left N₁ N₂), rwa ge_from_le at hn},
                    {apply le_trans (le_max_right N₁ N₂), rwa ge_from_le at hn}
                    },
        replace hb : abs (a n - b) < (ε / 2) := hN₁ n this.left,
        replace hc : abs (a n - c) < (ε / 2) := hN₂ n this.right,
        rwa abs_sub (a n) b at hb,
        suffices : abs (b - (a n) + (a n) - c) < ε,
            by {simp at this, from this},
        have hd : abs (a n - c) + abs (b - a n) < ε / 2 + ε / 2 := add_lt_add hc hb,
        simp at hd,
        have he : abs (b -a n + a n + -c) ≤ abs (b + -a n) + abs (a n + -c) :=
            by {suffices : abs (b + -a n + (a n + -c)) ≤ abs (b + -a n) + abs (a n + -c),
                    simp at this, rwa [sub_eq_add_neg b (a n), neg_add_cancel_right b (a n)],
                from abs_add (b + -a n) (a n + -c)},
        apply lt_of_le_of_lt he hd
        },
    have ha : ∀ (ε : ℝ), ε > 0 →  abs (b - c) < ε :=
        by {intros ε hε,
        cases this ε hε with N hN,
        have ha : N + 1 ≥ N := by {linarith},
        from hN (N + 1) ha
        },
    rwa ←(equality_def c b)
end

-- If (a n) is convergent then its bounded
theorem converge_is_bdd (a : ℕ → ℝ) : is_convergent a → seq_bounded a :=
begin
    unfold is_convergent,
    unfold seq_bounded,
    unfold seq_bounded_above,
    unfold seq_bounded_below,
    rintro ⟨l, hl⟩,
    have : (1 : ℝ) > 0 := by {linarith},
    -- Note that we have (hl 1 this) == ∃ (N : ℕ), ∀ (n : ℕ), n ≥ N → abs (a n - l) < 1
    -- then we can let the bound be max {a 1, a 2, ... , a (N - 1), l + 1}
    -- But how can I type this in LEAN I've got no idea! :/
    sorry
end

/- Can I define the addition of sequences through instances?
def seq := ℕ → ℝ

def seq_add : seq → seq → seq

instance seq_has_add : has_add seq := apply_instance
-/

-- Defining addition for sequences
def seq_add_seq (a : ℕ → ℝ) (b : ℕ → ℝ) := λ n : ℕ, a n + b n
notation a ` + ` b := seq_add_seq a b

def seq_add_real (a : ℕ → ℝ) (b : ℝ) := λ n : ℕ, a n + b
notation a ` + ` b := seq_add_real a b

-- Algebra of limits
theorem add_lim_conv (a b : ℕ → ℝ) (l m : ℝ) : a ⇒ l ∧ b ⇒ m → (a + b) ⇒ (l + m) :=
begin
    rintros ⟨ha, hb⟩ ε hε,
    have : ε / 2 > 0 := half_pos hε,
    cases ha (ε / 2) this with N₁ hN₁,
    cases hb (ε / 2) this with N₂ hN₂,
    let N : ℕ := max N₁ N₂,
    use N,
    intros n hn,
    have hrw : a n + b n - (l + m) = (a n - l) + (b n - m) := by {linarith},
    unfold seq_add_seq,
    rw hrw,
    have hmax : N ≥ N₁ ∧ N ≥ N₂ := 
        by {split,
            all_goals {rwa [ge_iff_le, le_max_iff], tauto}},
    suffices h : abs (a n - l) + abs (b n - m) < ε,
        from lt_of_le_of_lt (abs_add (a n - l) (b n - m)) h,
    have h : abs (a n - l) + abs (b n - m) < ε / 2 + ε / 2 := 
        by {from add_lt_add (hN₁ n (ge_trans hn hmax.left)) (hN₂ n (ge_trans hn hmax.right))},
    rwa add_halves' ε at h
end
 
lemma diff_seq_is_zero (a b : ℕ → ℝ) (l : ℝ) (h : a ⇒ l) : a = b + l → b ⇒ 0 :=
begin
    unfold seq_add_real, unfold converges_to,
    unfold converges_to at h,
    intro ha,
    rw ha at h, simp at h,
    suffices : ∀ (ε : ℝ), 0 < ε → (∃ (N : ℕ), ∀ (n : ℕ), N ≤ n → abs (b n) < ε),
        simpa,
    assumption
end

-- Defining multiplication of sequences
def seq_mul_seq (a : ℕ → ℝ) (b : ℕ → ℝ) := λ n : ℕ, a n * b n
notation a ` × ` b := seq_mul_seq a b

def seq_mul_real (a : ℕ → ℝ) (b : ℝ) := λ n : ℕ, a n * b
notation a ` × ` b := seq_mul_real a b

theorem mul_lim_conv (a b : ℕ → ℝ) (l m : ℝ) (ha : a ⇒ l) (hb : b ⇒ m) : (a × b) ⇒ l * m :=
begin
    sorry
end

-- Defining division of sequences (why is this noncomputable?)
noncomputable def seq_div_seq (a : ℕ → ℝ) (b : ℕ → ℝ) := λ n : ℕ, (a n) / (b n) 
notation a ` / ` b := seq_div_seq a b

noncomputable def seq_div_real (a : ℕ → ℝ) (b : ℝ) := λ n : ℕ, a n / b
notation a ` / ` b := seq_div_real a b

theorem div_lim_conv (a b : ℕ → ℝ) (l m : ℝ) (ha : a ⇒ l) (hb : b ⇒ m) (hc : m ≠ 0) : (a / b) ⇒ l / m :=
begin
    sorry
end

-- Defining monotone increasing and decreasing sequences
def mono_increasing (a : ℕ → ℝ) := ∀ n : ℕ, a n ≤ a (n + 1)
notation a ` ↑ ` := mono_increasing a

def mono_increasing_conv (a : ℕ → ℝ) (l : ℝ) := mono_increasing a ∧ a ⇒ l
notation a ` ↑ ` l := mono_increasing a l

def mono_decreasing (a : ℕ → ℝ) := ∀ n : ℕ, a (n + 1) ≤ a n
notation a ` ↓ ` := mono_decreasing a

def mono_decreasing_conv (a : ℕ → ℝ) (l : ℝ) := mono_decreasing a ∧ a ⇒ l
notation a ` ↓ ` l := mono_decreasing a l

lemma le_chain (N : ℕ) (b : ℕ → ℝ) (h : mono_increasing b) : ∀ n : ℕ, N ≤ n → b N ≤ b n :=
begin
    intros n hn,
    have ha : ∀ k : ℕ, b N ≤ b (N + k) :=
        by {intro k,
        induction k with k hk,
            {refl},
            {from le_trans hk (h (N + k))}
        },
    have : ∃ k : ℕ, N + k = n := nat.le.dest hn,
    cases this with k hk,
    rw ←hk,
    from ha k
end

-- Monotone increasing and bounded means convergent
theorem mono_increasing_means_conv (b : ℕ → ℝ) (h₁ : mono_increasing b) (h₂ : seq_bounded b) : is_convergent b :=
begin
    rcases h₂ with ⟨⟨N, habv⟩, hblw⟩,
    let α : set ℝ := {t : ℝ | ∃ n : ℕ, t = b n},
    have : ∃ M : ℝ, sup α M :=
        by {apply completeness α,
            {use b N, rintros s ⟨n, hs⟩,
            suffices : b n ≤ b N, rwa ←hs at this,
            from habv n
            },
            {suffices : b 0 ∈ α,
                apply set.not_eq_empty_iff_exists.mpr,
                use b 0, assumption,
            rw set.mem_set_of_eq,
            use 0
            }        
        },
    cases this with M hM,
    use M,
    intros ε hε,
    clear habv N,
    have : ∃ N : ℕ, M - ε < b N :=
        by {cases hM with hubd hnubd,
        unfold upper_bound at hnubd,
        push_neg at hnubd,
        have : M - ε < M := 
            by {rw gt_iff_lt at hε,
            from sub_lt_self M hε},
        rcases hnubd (M - ε) this with ⟨s, ⟨hs₁, hs₂⟩⟩,
        rw set.mem_set_of_eq at hs₁,
        cases hs₁ with n hn,
        use n, rwa ←hn
        },
    cases this with N hN,
    unfold mono_increasing at h₁, --delete this
    use N, intros n hn,
    rw abs_of_nonpos,
        {have : ∀ n : ℕ, N ≤ n → b N ≤ b n := le_chain N b h₁,
        suffices : M - ε < b n,
            simp, from sub_lt.mp this,
        from lt_of_lt_of_le hN (this n (iff.rfl.mp hn))
        },
        cases hM,
        have : b n ≤ M := by {apply hM_left, rwa set.mem_set_of_eq, use n},
        from sub_nonpos_of_le this
end

-- Defining order on sequences (is this necessary?)
def le_seq (a b : ℕ → ℝ) := ∀ n : ℕ, a n ≤ b n
notation a ` ≤* ` b := le_seq a b

def lt_seq (a b : ℕ → ℝ) := ∀ n : ℕ, a n < b n
notation a ` <* ` b := lt_seq a b

def ge_seq (a b : ℕ → ℝ) := ∀ n : ℕ, a n ≥ b n
notation a ` ≥* ` b := ge_seq a b

def gt_seq (a b : ℕ → ℝ) := ∀ n : ℕ, a n > b n
notation a ` >* ` b := gt_seq a b

-- Comparison of sequences
theorem le_lim (a b : ℕ → ℝ) (l m : ℝ) (ha : a ⇒ l) (hb : b ⇒ m) : (a ≤* b) → l ≤ m :=
begin -- Should probably scrap this proof...
    rw ←not_lt,
    intros h hlt,
    have hδ : (l - m) / 2 > 0 := half_pos (sub_pos.mpr hlt),
    cases ha ((l - m) / 2) hδ with N₁ hN₁,
    cases hb ((l - m) / 2) hδ with N₂ hN₂,
    let N := max N₁ N₂,
    have hmax : N ≥ N₁ ∧ N ≥ N₂ := 
        by {split,
            all_goals {rwa [ge_iff_le, le_max_iff], tauto}},
    /- suffices : abs (a N - l) + abs (b N - m) < (l - m) / 2,
        {have hα : abs (a N - l - b N + m) < (l - m) / 2 :=
            by {rw abs_sub (b N) m at this,
            have hβ : a N - l - b N + m = a N - l + (m - b N) := by simp,
            have hγ : abs (a N - l + (m - b N)) < (l - m) / 2 :=
                 lt_of_le_of_lt (abs_add (a N - l) (m - b N)) this,
            rwa ←hβ at hγ
            },
        have hβ : abs (a N - l - b N + m) = abs (a N - b N - (l - m)) := by simp,
        
        },
    -/
    replace hN₁ : abs (a N - l) < (l - m) / 2 := hN₁ N hmax.left,
    replace hN₂ : abs (b N - l) < (l - m) / 2 := hN₂ N hmax.right,
    rw abs_lt at hN₁,
    rw abs_lt at hN₂,
end

--set_option trace.simplify.rewrite true
--example (d b c : ℝ) : abs (d - b) < c ↔ (- c < (d - b) ∧ (d - b) < c) := by {library_search}


end M40002