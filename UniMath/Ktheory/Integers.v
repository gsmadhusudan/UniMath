(** * Integers *)

(** These results might as well be in hz.v . *)

Require Import algebra1b funextfun Utilities total2_paths GroupAction hz.
Require Nat.
Import Utilities.Notation Utilities.NatNotation.

Definition ℤ := hzaddabgr.
Definition toℤ (n:nat) : ℤ := nattohz n.
Definition toℤneg (n:nat) : ℤ := natnattohz O n.
Definition zero := toℤ 0.
Definition one := toℤ 1.

Open Scope hz_scope.

Definition hzabsvalnat n : hzabsval (natnattohz n 0) = n. (* move to hz.v *)
Proof. intros. unfold hzabsval. unfold setquotuniv. simpl.
       unfold hzabsvalint. simpl. destruct (natgthorleh n 0).
       { apply natminuseqn. } { exact (! (natleh0tois0 _ h)). } Defined.

Lemma hzsign_natnattohz m n : - natnattohz m n = natnattohz n m. (* move to hz.v *)
Proof. reflexivity.             (* don't change the proof *)
Defined.

Lemma hzsign_nattohz m : - nattohz m = natnattohz 0 m. (* move to hz.v *)
Proof. reflexivity.             (* don't change the proof *)
Defined.

Lemma hzsign_hzsign (i:hz) : - - i = i.
Proof. apply (grinvinv ℤ). Defined.

Definition hz_normal_form (i:ℤ) :=
  coprod (total2 (fun n => natnattohz n 0 = i))
         (total2 (fun n => natnattohz 0 (S n) = i)).

Definition hznf_pos n := _,, inl (n,,idpath _) : total2 hz_normal_form.

Definition hznf_neg n := _,, inr (n,,idpath _) : total2 hz_normal_form.

Definition hznf_zero := hznf_pos 0.

Definition hznf_neg_one := hznf_neg 0.

Definition hz_to_normal_form (i:ℤ) : hz_normal_form i.
Proof. intros. destruct (hzlthorgeh i 0) as [r|s].
       { apply inr. assert (a := hzabsvallth0 r). assert (b := hzlthtoneq _ _ r).
         assert (c := hzabsvalneq0 b). assert (d := natneq0togth0 _ c).
         assert (f := natgthtogehsn _ _ d). assert (g := minusplusnmm _ _ f).
         rewrite natpluscomm in g. simpl in g. exists (hzabsval i - 1)%nat.
         rewrite g. apply hzinvmaponpathsminus. exact a. }
       { apply inl. exists (hzabsval i). exact (hzabsvalgeh0 s). } Defined.

Lemma nattohz_inj {m n} : nattohz m = nattohz n -> m = n.
Proof. exact (invmaponpathsincl _ isinclnattohz). Defined.

Lemma hzdichot {m n} : neg (nattohz m = - nattohz (S n)).
Proof. intros. intro e. assert (d := ap hzsign e); clear e.
       rewrite hzsign_hzsign in d.
       assert( f := ap (fun i => nattohz m + i) d); simpl in f; clear d.
       change (nattohz m + - nattohz m) with (nattohz m - nattohz m) in f.
       rewrite hzrminus in f. change (0 = nattohz (m + S n)) in f.
       assert (g := nattohz_inj f); clear f. rewrite natpluscomm in g.
       exact (negpaths0sx _ g). Defined.

Definition negpos' : isweq (@pr1 _ hz_normal_form).
Proof. apply isweqpr1; intro i.
       exists (hz_to_normal_form i).
       generalize (hz_to_normal_form i) as s.
       intros [[m p]|[m p]] [[n q]|[n q]].
       { apply (ap (@ii1 (total2 (fun n => natnattohz n 0 = i)) 
                         (total2 (fun n => natnattohz 0 (S n) = i)))).
         apply (proofirrelevance _ (isinclnattohz i)). }
       { apply fromempty. assert (r := p@!q); clear p q. apply (hzdichot r). }
       { apply fromempty. assert (r := q@!p); clear p q. apply (hzdichot r). }
       { apply (ap (@ii2 (total2 (fun n => natnattohz n 0 = i)) 
                         (total2 (fun n => natnattohz 0 (S n) = i)))).
         assert (p' := ap hzsign p). assert (q' := ap hzsign q).
         change (- natnattohz O (S m)) with  (nattohz (S m)) in p'.
         change (- natnattohz O (S n)) with  (nattohz (S n)) in q'.
         assert (c := proofirrelevance _ (isinclnattohz (-i)) (S m,,p') (S n,,q')).
         assert (d := ap pr1 c); simpl in d.
         assert (e := invmaponpathsS _ _ d); clear d.
         apply (pair_path_props (!e)). intro k. apply setproperty. } Defined.

Definition negpos_weq := weqpair _ negpos' : weq (total2 hz_normal_form) ℤ.

Definition negpos : weq (coprod nat nat) ℤ. (* ℤ = (-inf,-1) + (0,inf) *)
Proof. refine (weqpair _ (gradth _ _ _ _)).
       { intros [n'|n]. 
         { exact (natnattohz 0 (S n')). } { exact (natnattohz n 0). } }
       { intro i. destruct (hz_to_normal_form i) as [[n p]|[m q]].
         { exact (inr n). } { exact (inl m). } }
       { intros [n'|n].
         { simpl. rewrite natminuseqn. reflexivity. }
         { simpl. rewrite hzabsvalnat. reflexivity. } } 
       { simpl. intro i. 
         destruct (hz_to_normal_form i) as [[n p]|[m q]].
         { exact p. } { exact q. } }
Defined.

Lemma hzminusplus (x y:hz) : -(x+y) = (-x) + (-y). (* move to hz.v *)
Proof. intros. apply (hzplusrcan _ _ (x+y)). rewrite hzlminus. 
       rewrite (hzpluscomm (-x)). rewrite (hzplusassoc (-y)).
       rewrite <- (hzplusassoc (-x)). rewrite hzlminus. rewrite hzplusl0.
       rewrite hzlminus. reflexivity. Defined.

Definition loop_power {Y} {y:Y} (l:y = y) (n:ℤ) : y = y.
Proof. intros. assert (m := loop_power_nat l (hzabsval n)).
       destruct (hzlthorgeh n 0%hz). { exact (!m). } { exact m. } Defined.
