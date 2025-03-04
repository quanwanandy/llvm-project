; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -passes=slp-vectorizer -S < %s | FileCheck %s

; Given LLVM IR caused associative reduction matching routine crash in SLP.
; The routines begins with select as integer Umax reduction kind
; and then follows to llvm.umax intrinsic call which also matched
; to UMax and thus same reduction kind is returned.
; The routine's later code merely assumes the instruction to be a select.

define dso_local void @test(i1 %arg) {
; CHECK-LABEL: @test(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br i1 %arg, label [[NEXT:%.*]], label [[THEN:%.*]]
; CHECK:       then:
; CHECK-NEXT:    [[UM:%.*]] = call i8 @llvm.umax.i8(i8 0, i8 undef)
; CHECK-NEXT:    [[SELCMP:%.*]] = icmp ult i8 [[UM]], undef
; CHECK-NEXT:    [[I0:%.*]] = select i1 [[SELCMP]], i8 undef, i8 [[UM]]
; CHECK-NEXT:    br label [[NEXT]]
; CHECK:       next:
; CHECK-NEXT:    [[T7_0:%.*]] = phi i8 [ undef, [[ENTRY:%.*]] ], [ [[I0]], [[THEN]] ]
; CHECK-NEXT:    ret void
;
entry:
  br i1 %arg, label %next, label %then

then:
  %um = call i8 @llvm.umax.i8(i8 0, i8 undef)
  %selcmp = icmp ult i8 %um, undef
  %i0 = select i1 %selcmp, i8 undef, i8 %um
  br label %next

next:
  %t7.0 = phi i8 [ undef, %entry ], [ %i0, %then ]
  ret void
}

declare i8 @llvm.umax.i8(i8, i8)

declare i32 @llvm.smin.i32(i32, i32)
declare i32 @llvm.umin.i32(i32, i32)

; Given LLVM IR caused crash in SLP.
define void @test2() {
; CHECK-LABEL: @test2(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP0:%.*]] = call <4 x i32> @llvm.smin.v4i32(<4 x i32> <i32 3, i32 2, i32 1, i32 undef>, <4 x i32> <i32 undef, i32 undef, i32 undef, i32 0>)
; CHECK-NEXT:    [[TMP1:%.*]] = sub nsw <4 x i32> undef, [[TMP0]]
; CHECK-NEXT:    [[TMP2:%.*]] = call i32 @llvm.vector.reduce.umin.v4i32(<4 x i32> [[TMP1]])
; CHECK-NEXT:    [[TMP3:%.*]] = call i32 @llvm.umin.i32(i32 [[TMP2]], i32 77)
; CHECK-NEXT:    [[E:%.*]] = icmp ugt i32 [[TMP3]], 1
; CHECK-NEXT:    ret void
;
entry:
  %smin0 = call i32 @llvm.smin.i32(i32 undef, i32 0)
  %smin1 = call i32 @llvm.smin.i32(i32 undef, i32 1)
  %smin2 = call i32 @llvm.smin.i32(i32 undef, i32 2)
  %smin3 = call i32 @llvm.smin.i32(i32 undef, i32 3)
  %a = sub nsw i32 undef, %smin0
  %b = sub nsw i32 undef, %smin1
  %c = sub nsw i32 undef, %smin2
  %d = sub nsw i32 undef, %smin3
  %umin0 = call i32 @llvm.umin.i32(i32 %d, i32 %c)
  %umin1 = call i32 @llvm.umin.i32(i32 %umin0, i32 %b)
  %umin2 = call i32 @llvm.umin.i32(i32 %umin1, i32 %a)
  %umin3 = call i32 @llvm.umin.i32(i32 %umin2, i32 77)
  %e = icmp ugt i32 %umin3, 1
  ret void
}
