Require Export Coq.extraction.Extraction.
Require Export Coq.extraction.ExtrHaskellBasic.
Require Export Coq.extraction.ExtrHaskellString.
Require Import Coq.Lists.List.
Require Import Coq.Strings.String.
Require Crypto.Util.Strings.String.
Require Import Crypto.CLI.
Require Import Crypto.Util.Notations.
Import ListNotations. Local Open Scope string_scope.

Global Set Warnings Append "-extraction-opaque-accessed".
Extraction Language Haskell.
Global Unset Extraction Optimize.

Axiom IO_unit : Set.
Axiom _IO : Set -> Set.
Axiom printf_string : string -> _IO unit.
Axiom getArgs : _IO (list string).
Axiom getProgName : _IO string.
Axiom raise_failure : string -> _IO unit.
Axiom _IO_bind : forall A B, _IO A -> (A -> _IO B) -> _IO B.
Axiom _IO_return : forall A : Set, A -> _IO A.
Axiom cast_io : _IO unit -> IO_unit.
Extract Constant printf_string =>
"\s -> Text.Printf.printf ""%s"" s".
Extract Constant _IO "a" => "GHC.Base.IO a".
Extract Inlined Constant getArgs => "System.Environment.getArgs".
Extract Inlined Constant getProgName => "System.Environment.getProgName".
Extract Constant raise_failure => "\x -> Prelude.error x".
Extract Inlined Constant _IO_bind => "(Prelude.>>=)".
Extract Inlined Constant _IO_return => "return".
Extract Inlined Constant IO_unit => "GHC.Base.IO ()".
Extract Inlined Constant cast_io => "".

Local Notation "x <- y ; f" := (_IO_bind _ _ y (fun x => f)).

Definition main_gen
           {supported_languages : ForExtraction.supported_languagesT}
           (PipelineMain : forall (A := _)
                                  (argv : list String.string)
                                  (success : list String.string -> A)
                                  (error : list String.string -> A),
               A)
  : IO_unit
  := cast_io
       (argv <- getArgs;
       prog <- getProgName;
       PipelineMain
         (prog::argv)
         (fun res => printf_string
                       (String.concat "" res))
         (fun err => raise_failure (String.concat String.NewLine err))).

Local Existing Instance ForExtraction.default_supported_languages.

Module UnsaturatedSolinas.
  Definition main : IO_unit
    := main_gen ForExtraction.UnsaturatedSolinas.PipelineMain.
End UnsaturatedSolinas.

Module WordByWordMontgomery.
  Definition main : IO_unit
    := main_gen ForExtraction.WordByWordMontgomery.PipelineMain.
End WordByWordMontgomery.

Module SaturatedSolinas.
  Definition main : IO_unit
    := main_gen ForExtraction.SaturatedSolinas.PipelineMain.
End SaturatedSolinas.

Module BaseConversion.
  Definition main : IO_unit
    := main_gen ForExtraction.BaseConversion.PipelineMain.
End BaseConversion.
