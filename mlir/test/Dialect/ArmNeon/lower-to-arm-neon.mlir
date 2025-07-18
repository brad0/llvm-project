// RUN: mlir-opt -transform-interpreter  %s | FileCheck %s

// CHECK-LABEL: vector_arm_neon_mixed_types
// CHECK-SAME:    %[[A0:.*]]: vector<2x8xi8>, %[[A1:.*]]: vector<2x8xi4>, %[[A2:.*]]: vector<2x2xi32>
// CHECK-DAG: %[[D0:.*]] = arith.extsi %[[A1]] : vector<2x8xi4> to vector<2x8xi8>
// CHECK-DAG: %[[D1:.*]] = vector.shape_cast %[[A0]] : vector<2x8xi8> to vector<16xi8>
// CHECK-DAG: %[[D2:.*]] = vector.shape_cast %[[D0]] : vector<2x8xi8> to vector<16xi8>
// CHECK-DAG: %[[D3:.*]] = vector.shape_cast %[[A2]] : vector<2x2xi32> to vector<4xi32>
// CHECK-DAG: %[[D4:.*]] = arm_neon.intr.smmla %[[D3]], %[[D1]], %[[D2]] : vector<16xi8> to vector<4xi32>
// CHECK-DAG: %[[D5:.*]] = vector.shape_cast %[[D4]] : vector<4xi32> to vector<2x2xi32>
func.func @vector_arm_neon_mixed_types(%lhs: vector<2x8xi8>, %rhs: vector<2x8xi4>, %acc : vector<2x2xi32>) -> vector<2x2xi32> {
  %lhs_extsi = arith.extsi %lhs : vector<2x8xi8> to vector<2x8xi32>
  %rhs_extsi = arith.extsi %rhs : vector<2x8xi4> to vector<2x8xi32>
  %res = vector.contract {indexing_maps = [affine_map<(d0, d1, d2) -> (d0, d2)>, affine_map<(d0, d1, d2) -> (d1, d2)>, affine_map<(d0, d1, d2) -> (d0, d1)>], iterator_types = ["parallel", "parallel", "reduction"], kind = #vector.kind<add>} %lhs_extsi, %rhs_extsi, %acc : vector<2x8xi32>, vector<2x8xi32> into vector<2x2xi32>
  return %res : vector<2x2xi32>
}

// -----

// CHECK-LABEL: vector_arm_neon_implicit_extsi
// CHECK-SAME:    %[[LHS:.+]]: vector<2x8xi8>, %[[RHS:.+]]: vector<2x8xi8>, %[[ACC:.+]]: vector<2x2xi32>
// CHECK:       %[[L:.+]] = vector.shape_cast %[[LHS]] : vector<2x8xi8> to vector<16xi8>
// CHECK:       %[[R:.+]] = vector.shape_cast %[[RHS]] : vector<2x8xi8> to vector<16xi8>
// CHECK:       %[[A:.+]] = vector.shape_cast %[[ACC]] : vector<2x2xi32> to vector<4xi32>
// CHECK:       %[[M:.+]] = arm_neon.intr.smmla %[[A]], %[[L]], %[[R]] : vector<16xi8> to vector<4xi32>
// CHECK:       %{{.+}} = vector.shape_cast %[[M]] : vector<4xi32> to vector<2x2xi32>
func.func @vector_arm_neon_implicit_extsi(%lhs: vector<2x8xi8>, %rhs: vector<2x8xi8>, %acc : vector<2x2xi32>) -> vector<2x2xi32> {
  %res = vector.contract {indexing_maps = [affine_map<(d0, d1, d2) -> (d0, d2)>, affine_map<(d0, d1, d2) -> (d1, d2)>, affine_map<(d0, d1, d2) -> (d0, d1)>], iterator_types = ["parallel", "parallel", "reduction"], kind = #vector.kind<add>} %lhs, %rhs, %acc : vector<2x8xi8>, vector<2x8xi8> into vector<2x2xi32>
  return %res : vector<2x2xi32>
}

// -----

// CHECK-LABEL: vector_arm_neon_signed_signed
// CHECK-SAME:    %[[LHS:.+]]: vector<2x8xi8>, %[[RHS:.+]]: vector<2x8xi8>, %[[ACC:.+]]: vector<2x2xi32>
// CHECK:       %[[L:.+]] = vector.shape_cast %[[LHS]] : vector<2x8xi8> to vector<16xi8>
// CHECK:       %[[R:.+]] = vector.shape_cast %[[RHS]] : vector<2x8xi8> to vector<16xi8>
// CHECK:       %[[A:.+]] = vector.shape_cast %[[ACC]] : vector<2x2xi32> to vector<4xi32>
// CHECK:       %[[M:.+]] = arm_neon.intr.smmla %[[A]], %[[L]], %[[R]] : vector<16xi8> to vector<4xi32>
// CHECK:       %{{.+}} = vector.shape_cast %[[M]] : vector<4xi32> to vector<2x2xi32>
func.func @vector_arm_neon_signed_signed(%lhs: vector<2x8xi8>, %rhs: vector<2x8xi8>, %acc : vector<2x2xi32>) -> vector<2x2xi32> {
  %lhs_extsi = arith.extsi %lhs : vector<2x8xi8> to vector<2x8xi32>
  %rhs_extsi = arith.extsi %rhs : vector<2x8xi8> to vector<2x8xi32>
  %res = vector.contract {indexing_maps = [affine_map<(d0, d1, d2) -> (d0, d2)>, affine_map<(d0, d1, d2) -> (d1, d2)>, affine_map<(d0, d1, d2) -> (d0, d1)>], iterator_types = ["parallel", "parallel", "reduction"], kind = #vector.kind<add>} %lhs_extsi, %rhs_extsi, %acc : vector<2x8xi32>, vector<2x8xi32> into vector<2x2xi32>
  return %res : vector<2x2xi32>
}

// -----

// CHECK-LABEL: vector_arm_neon_unsigned_signed
// CHECK-SAME:    %[[LHS:.+]]: vector<2x8xi8>, %[[RHS:.+]]: vector<2x8xi8>, %[[ACC:.+]]: vector<2x2xi32>
// CHECK:       %[[L:.+]] = vector.shape_cast %[[LHS]] : vector<2x8xi8> to vector<16xi8>
// CHECK:       %[[R:.+]] = vector.shape_cast %[[RHS]] : vector<2x8xi8> to vector<16xi8>
// CHECK:       %[[A:.+]] = vector.shape_cast %[[ACC]] : vector<2x2xi32> to vector<4xi32>
// CHECK:       %[[M:.+]] = arm_neon.intr.usmmla %[[A]], %[[L]], %[[R]] : vector<16xi8> to vector<4xi32>
// CHECK:       %{{.+}} = vector.shape_cast %[[M]] : vector<4xi32> to vector<2x2xi32>
func.func @vector_arm_neon_unsigned_signed(%lhs: vector<2x8xi8>, %rhs: vector<2x8xi8>, %acc : vector<2x2xi32>) -> vector<2x2xi32> {
  %lhs_extsi = arith.extui %lhs : vector<2x8xi8> to vector<2x8xi32>
  %rhs_extsi = arith.extsi %rhs : vector<2x8xi8> to vector<2x8xi32>
  %res = vector.contract {indexing_maps = [affine_map<(d0, d1, d2) -> (d0, d2)>, affine_map<(d0, d1, d2) -> (d1, d2)>, affine_map<(d0, d1, d2) -> (d0, d1)>], iterator_types = ["parallel", "parallel", "reduction"], kind = #vector.kind<add>} %lhs_extsi, %rhs_extsi, %acc : vector<2x8xi32>, vector<2x8xi32> into vector<2x2xi32>
  return %res : vector<2x2xi32>
}

// -----

// CHECK-LABEL: vector_arm_neon_unsigned_unsigned
// CHECK-SAME:    %[[LHS:.+]]: vector<2x8xi8>, %[[RHS:.+]]: vector<2x8xi8>, %[[ACC:.+]]: vector<2x2xi32>
// CHECK:       %[[L:.+]] = vector.shape_cast %[[LHS]] : vector<2x8xi8> to vector<16xi8>
// CHECK:       %[[R:.+]] = vector.shape_cast %[[RHS]] : vector<2x8xi8> to vector<16xi8>
// CHECK:       %[[A:.+]] = vector.shape_cast %[[ACC]] : vector<2x2xi32> to vector<4xi32>
// CHECK:       %[[M:.+]] = arm_neon.intr.ummla %[[A]], %[[L]], %[[R]] : vector<16xi8> to vector<4xi32>
// CHECK:       %{{.+}} = vector.shape_cast %[[M]] : vector<4xi32> to vector<2x2xi32>
func.func @vector_arm_neon_unsigned_unsigned(%lhs: vector<2x8xi8>, %rhs: vector<2x8xi8>, %acc : vector<2x2xi32>) -> vector<2x2xi32> {
  %lhs_extsi = arith.extui %lhs : vector<2x8xi8> to vector<2x8xi32>
  %rhs_extsi = arith.extui %rhs : vector<2x8xi8> to vector<2x8xi32>
  %res = vector.contract {indexing_maps = [affine_map<(d0, d1, d2) -> (d0, d2)>, affine_map<(d0, d1, d2) -> (d1, d2)>, affine_map<(d0, d1, d2) -> (d0, d1)>], iterator_types = ["parallel", "parallel", "reduction"], kind = #vector.kind<add>} %lhs_extsi, %rhs_extsi, %acc : vector<2x8xi32>, vector<2x8xi32> into vector<2x2xi32>
  return %res : vector<2x2xi32>
}

// -----

// CHECK-LABEL: vector_arm_neon_signed_unsigned
// CHECK-SAME:    %[[LHS:.+]]: vector<2x8xi8>, %[[RHS:.+]]: vector<2x8xi8>, %[[ACC:.+]]: vector<2x2xi32>
// CHECK:       %[[ACC_T:.+]] = vector.transpose %[[ACC]], [1, 0] : vector<2x2xi32> to vector<2x2xi32>
// CHECK:       %[[L:.+]] = vector.shape_cast %[[LHS]] : vector<2x8xi8> to vector<16xi8>
// CHECK:       %[[R:.+]] = vector.shape_cast %[[RHS]] : vector<2x8xi8> to vector<16xi8>
// CHECK:       %[[A:.+]] = vector.shape_cast %[[ACC_T]] : vector<2x2xi32> to vector<4xi32>
// CHECK:       %[[M:.+]] = arm_neon.intr.usmmla %[[A]], %[[R]], %[[L]] : vector<16xi8> to vector<4xi32>
// CHECK:       %[[OUT_T:.+]] = vector.shape_cast %[[M]] : vector<4xi32> to vector<2x2xi32>
// CHECK:       %{{.+}} = vector.transpose %[[OUT_T]], [1, 0] : vector<2x2xi32> to vector<2x2xi32>
func.func @vector_arm_neon_signed_unsigned(%lhs: vector<2x8xi8>, %rhs: vector<2x8xi8>, %acc : vector<2x2xi32>) -> vector<2x2xi32> {
  %lhs_extsi = arith.extsi %lhs : vector<2x8xi8> to vector<2x8xi32>
  %rhs_extsi = arith.extui %rhs : vector<2x8xi8> to vector<2x8xi32>
  %res = vector.contract {indexing_maps = [affine_map<(d0, d1, d2) -> (d0, d2)>, affine_map<(d0, d1, d2) -> (d1, d2)>, affine_map<(d0, d1, d2) -> (d0, d1)>], iterator_types = ["parallel", "parallel", "reduction"], kind = #vector.kind<add>} %lhs_extsi, %rhs_extsi, %acc : vector<2x8xi32>, vector<2x8xi32> into vector<2x2xi32>
  return %res : vector<2x2xi32>
}

// -----

// CHECK-LABEL: vector_arm_neon_unroll
// CHECK-SAME: %[[VAL_0:.*]]: vector<4x8xi8>, %[[VAL_1:.*]]: vector<4x8xi8>, %[[VAL_2:.*]]: vector<4x4xi32>
// CHECK-DAG:  %[[VAL_3:.*]] = arith.constant dense<0> : vector<4x4xi32>
// CHECK-DAG:  %[[VAL_4:.*]] = vector.extract_strided_slice %[[VAL_0]] {offsets = [0, 0], sizes = [2, 8], strides = [1, 1]} : vector<4x8xi8> to vector<2x8xi8>
// CHECK-DAG:  %[[VAL_5:.*]] = vector.extract_strided_slice %[[VAL_1]] {offsets = [0, 0], sizes = [2, 8], strides = [1, 1]} : vector<4x8xi8> to vector<2x8xi8>
// CHECK-DAG:  %[[VAL_6:.*]] = vector.extract_strided_slice %[[VAL_2]] {offsets = [0, 0], sizes = [2, 2], strides = [1, 1]} : vector<4x4xi32> to vector<2x2xi32>
// CHECK-DAG:  %[[VAL_7:.*]] = vector.shape_cast %[[VAL_4]] : vector<2x8xi8> to vector<16xi8>
// CHECK-DAG:  %[[VAL_8:.*]] = vector.shape_cast %[[VAL_5]] : vector<2x8xi8> to vector<16xi8>
// CHECK-DAG:  %[[VAL_9:.*]] = vector.shape_cast %[[VAL_6]] : vector<2x2xi32> to vector<4xi32>
// CHECK-DAG:  %[[VAL_10:.*]] = arm_neon.intr.smmla %[[VAL_9]], %[[VAL_7]], %[[VAL_8]] : vector<16xi8> to vector<4xi32>
// CHECK-DAG:  %[[VAL_11:.*]] = vector.shape_cast %[[VAL_10]] : vector<4xi32> to vector<2x2xi32>
// CHECK-DAG:  %[[VAL_12:.*]] = vector.insert_strided_slice %[[VAL_11]], %[[VAL_3]] {offsets = [0, 0], strides = [1, 1]} : vector<2x2xi32> into vector<4x4xi32>
// CHECK-DAG:  %[[VAL_13:.*]] = vector.extract_strided_slice %[[VAL_0]] {offsets = [0, 0], sizes = [2, 8], strides = [1, 1]} : vector<4x8xi8> to vector<2x8xi8>
// CHECK-DAG:  %[[VAL_14:.*]] = vector.extract_strided_slice %[[VAL_1]] {offsets = [2, 0], sizes = [2, 8], strides = [1, 1]} : vector<4x8xi8> to vector<2x8xi8>
// CHECK-DAG:  %[[VAL_15:.*]] = vector.extract_strided_slice %[[VAL_2]] {offsets = [0, 2], sizes = [2, 2], strides = [1, 1]} : vector<4x4xi32> to vector<2x2xi32>
// CHECK-DAG:  %[[VAL_16:.*]] = vector.shape_cast %[[VAL_13]] : vector<2x8xi8> to vector<16xi8>
// CHECK-DAG:  %[[VAL_17:.*]] = vector.shape_cast %[[VAL_14]] : vector<2x8xi8> to vector<16xi8>
// CHECK-DAG:  %[[VAL_18:.*]] = vector.shape_cast %[[VAL_15]] : vector<2x2xi32> to vector<4xi32>
// CHECK-DAG:  %[[VAL_19:.*]] = arm_neon.intr.smmla %[[VAL_18]], %[[VAL_16]], %[[VAL_17]] : vector<16xi8> to vector<4xi32>
// CHECK-DAG:  %[[VAL_20:.*]] = vector.shape_cast %[[VAL_19]] : vector<4xi32> to vector<2x2xi32>
// CHECK-DAG:  %[[VAL_21:.*]] = vector.insert_strided_slice %[[VAL_20]], %[[VAL_12]] {offsets = [0, 2], strides = [1, 1]} : vector<2x2xi32> into vector<4x4xi32>
// CHECK-DAG:  %[[VAL_22:.*]] = vector.extract_strided_slice %[[VAL_0]] {offsets = [2, 0], sizes = [2, 8], strides = [1, 1]} : vector<4x8xi8> to vector<2x8xi8>
// CHECK-DAG:  %[[VAL_23:.*]] = vector.extract_strided_slice %[[VAL_1]] {offsets = [0, 0], sizes = [2, 8], strides = [1, 1]} : vector<4x8xi8> to vector<2x8xi8>
// CHECK-DAG:  %[[VAL_24:.*]] = vector.extract_strided_slice %[[VAL_2]] {offsets = [2, 0], sizes = [2, 2], strides = [1, 1]} : vector<4x4xi32> to vector<2x2xi32>
// CHECK-DAG:  %[[VAL_25:.*]] = vector.shape_cast %[[VAL_22]] : vector<2x8xi8> to vector<16xi8>
// CHECK-DAG:  %[[VAL_26:.*]] = vector.shape_cast %[[VAL_23]] : vector<2x8xi8> to vector<16xi8>
// CHECK-DAG:  %[[VAL_27:.*]] = vector.shape_cast %[[VAL_24]] : vector<2x2xi32> to vector<4xi32>
// CHECK-DAG:  %[[VAL_28:.*]] = arm_neon.intr.smmla %[[VAL_27]], %[[VAL_25]], %[[VAL_26]] : vector<16xi8> to vector<4xi32>
// CHECK-DAG:  %[[VAL_29:.*]] = vector.shape_cast %[[VAL_28]] : vector<4xi32> to vector<2x2xi32>
// CHECK-DAG:  %[[VAL_30:.*]] = vector.insert_strided_slice %[[VAL_29]], %[[VAL_21]] {offsets = [2, 0], strides = [1, 1]} : vector<2x2xi32> into vector<4x4xi32>
// CHECK-DAG:  %[[VAL_31:.*]] = vector.extract_strided_slice %[[VAL_0]] {offsets = [2, 0], sizes = [2, 8], strides = [1, 1]} : vector<4x8xi8> to vector<2x8xi8>
// CHECK-DAG:  %[[VAL_32:.*]] = vector.extract_strided_slice %[[VAL_1]] {offsets = [2, 0], sizes = [2, 8], strides = [1, 1]} : vector<4x8xi8> to vector<2x8xi8>
// CHECK-DAG:  %[[VAL_33:.*]] = vector.extract_strided_slice %[[VAL_2]] {offsets = [2, 2], sizes = [2, 2], strides = [1, 1]} : vector<4x4xi32> to vector<2x2xi32>
// CHECK-DAG:  %[[VAL_34:.*]] = vector.shape_cast %[[VAL_31]] : vector<2x8xi8> to vector<16xi8>
// CHECK-DAG:  %[[VAL_35:.*]] = vector.shape_cast %[[VAL_32]] : vector<2x8xi8> to vector<16xi8>
// CHECK-DAG:  %[[VAL_36:.*]] = vector.shape_cast %[[VAL_33]] : vector<2x2xi32> to vector<4xi32>
// CHECK-DAG:  %[[VAL_37:.*]] = arm_neon.intr.smmla %[[VAL_36]], %[[VAL_34]], %[[VAL_35]] : vector<16xi8> to vector<4xi32>
// CHECK-DAG:  %[[VAL_38:.*]] = vector.shape_cast %[[VAL_37]] : vector<4xi32> to vector<2x2xi32>
// CHECK-DAG:  %[[VAL_39:.*]] = vector.insert_strided_slice %[[VAL_38]], %[[VAL_30]] {offsets = [2, 2], strides = [1, 1]} : vector<2x2xi32> into vector<4x4xi32>
// CHECK-DAG:  return %[[VAL_39]] : vector<4x4xi32>
// CHECK-DAG:  }
func.func @vector_arm_neon_unroll(%lhs: vector<4x8xi8>, %rhs: vector<4x8xi8>, %acc : vector<4x4xi32>) -> vector<4x4xi32> {
  %lhs_extsi = arith.extsi %lhs : vector<4x8xi8> to vector<4x8xi32>
  %rhs_extsi = arith.extsi %rhs : vector<4x8xi8> to vector<4x8xi32>
  %res = vector.contract {indexing_maps = [affine_map<(d0, d1, d2) -> (d0, d2)>, affine_map<(d0, d1, d2) -> (d1, d2)>, affine_map<(d0, d1, d2) -> (d0, d1)>], iterator_types = ["parallel", "parallel", "reduction"], kind = #vector.kind<add>} %lhs_extsi, %rhs_extsi, %acc : vector<4x8xi32>, vector<4x8xi32> into vector<4x4xi32>
  return %res : vector<4x4xi32>
}

// -----

// CHECK-LABEL:   func.func @vector_arm_neon_mixed_unroll(
// CHECK-SAME:                                                       %[[VAL_0:.*]]: vector<4x8xi8>,
// CHECK-SAME:                                                       %[[VAL_1:.*]]: vector<2x8xi4>,
// CHECK-SAME:                                                       %[[VAL_2:.*]]: vector<4x2xi32>) -> vector<4x2xi32> {
// CHECK-DAG:  %[[VAL_3:.*]] = arith.constant dense<0> : vector<4x2xi32>
// CHECK-DAG:  %[[VAL_4:.*]] = arith.extsi %[[VAL_1]] : vector<2x8xi4> to vector<2x8xi8>
// CHECK-DAG:  %[[VAL_5:.*]] = vector.extract_strided_slice %[[VAL_0]] {offsets = [0, 0], sizes = [2, 8], strides = [1, 1]} : vector<4x8xi8> to vector<2x8xi8>
// CHECK-DAG:  %[[VAL_6:.*]] = vector.extract_strided_slice %[[VAL_2]] {offsets = [0, 0], sizes = [2, 2], strides = [1, 1]} : vector<4x2xi32> to vector<2x2xi32>
// CHECK-DAG:  %[[VAL_7:.*]] = vector.shape_cast %[[VAL_5]] : vector<2x8xi8> to vector<16xi8>
// CHECK-DAG:  %[[VAL_8:.*]] = vector.shape_cast %[[VAL_4]] : vector<2x8xi8> to vector<16xi8>
// CHECK-DAG:  %[[VAL_9:.*]] = vector.shape_cast %[[VAL_6]] : vector<2x2xi32> to vector<4xi32>
// CHECK-DAG:  %[[VAL_10:.*]] = arm_neon.intr.smmla %[[VAL_9]], %[[VAL_7]], %[[VAL_8]] : vector<16xi8> to vector<4xi32>
// CHECK-DAG:  %[[VAL_11:.*]] = vector.shape_cast %[[VAL_10]] : vector<4xi32> to vector<2x2xi32>
// CHECK-DAG:  %[[VAL_12:.*]] = vector.insert_strided_slice %[[VAL_11]], %[[VAL_3]] {offsets = [0, 0], strides = [1, 1]} : vector<2x2xi32> into vector<4x2xi32>
// CHECK-DAG:  %[[VAL_13:.*]] = vector.extract_strided_slice %[[VAL_0]] {offsets = [2, 0], sizes = [2, 8], strides = [1, 1]} : vector<4x8xi8> to vector<2x8xi8>
// CHECK-DAG:  %[[VAL_14:.*]] = vector.extract_strided_slice %[[VAL_2]] {offsets = [2, 0], sizes = [2, 2], strides = [1, 1]} : vector<4x2xi32> to vector<2x2xi32>
// CHECK-DAG:  %[[VAL_15:.*]] = vector.shape_cast %[[VAL_13]] : vector<2x8xi8> to vector<16xi8>
// CHECK-DAG:  %[[VAL_16:.*]] = vector.shape_cast %[[VAL_4]] : vector<2x8xi8> to vector<16xi8>
// CHECK-DAG:  %[[VAL_17:.*]] = vector.shape_cast %[[VAL_14]] : vector<2x2xi32> to vector<4xi32>
// CHECK-DAG:  %[[VAL_18:.*]] = arm_neon.intr.smmla %[[VAL_17]], %[[VAL_15]], %[[VAL_16]] : vector<16xi8> to vector<4xi32>
// CHECK-DAG:  %[[VAL_19:.*]] = vector.shape_cast %[[VAL_18]] : vector<4xi32> to vector<2x2xi32>
// CHECK-DAG:  %[[VAL_20:.*]] = vector.insert_strided_slice %[[VAL_19]], %[[VAL_12]] {offsets = [2, 0], strides = [1, 1]} : vector<2x2xi32> into vector<4x2xi32>
// CHECK-DAG:  return %[[VAL_20]] : vector<4x2xi32>
// CHECK-DAG:  }
func.func @vector_arm_neon_mixed_unroll(%lhs: vector<4x8xi8>, %rhs: vector<2x8xi4>, %acc : vector<4x2xi32>) -> vector<4x2xi32> {
  %lhs_extsi = arith.extsi %lhs : vector<4x8xi8> to vector<4x8xi32>
  %rhs_extsi = arith.extsi %rhs : vector<2x8xi4> to vector<2x8xi32>
  %res = vector.contract {indexing_maps = [affine_map<(d0, d1, d2) -> (d0, d2)>, affine_map<(d0, d1, d2) -> (d1, d2)>, affine_map<(d0, d1, d2) -> (d0, d1)>], iterator_types = ["parallel", "parallel", "reduction"], kind = #vector.kind<add>} %lhs_extsi, %rhs_extsi, %acc : vector<4x8xi32>, vector<2x8xi32> into vector<4x2xi32>
  return %res : vector<4x2xi32>
}

// -----

// CHECK-LABEL:   func.func @vector_arm_neon_unroll_incompatible_shape(
// CHECK-DAG:  %[[result:.*]] = vector.contract
func.func @vector_arm_neon_unroll_incompatible_shape(%lhs: vector<4x12xi8>, %rhs: vector<4x12xi8>, %acc : vector<4x4xi32>) -> vector<4x4xi32> {
  %lhs_extsi = arith.extsi %lhs : vector<4x12xi8> to vector<4x12xi32>
  %rhs_extsi = arith.extsi %rhs : vector<4x12xi8> to vector<4x12xi32>
  %res = vector.contract {indexing_maps = [affine_map<(d0, d1, d2) -> (d0, d2)>, affine_map<(d0, d1, d2) -> (d1, d2)>, affine_map<(d0, d1, d2) -> (d0, d1)>], iterator_types = ["parallel", "parallel", "reduction"], kind = #vector.kind<add>} %lhs_extsi, %rhs_extsi, %acc : vector<4x12xi32>, vector<4x12xi32> into vector<4x4xi32>
  return %res : vector<4x4xi32>
}

// -----

// CHECK-LABEL:   func.func @vector_arm_neon_vecmat_unroll(
// CHECK-SAME:  %[[VAL_0:.*]]: vector<8xi8>,
// CHECK-SAME:  %[[VAL_1:.*]]: vector<8x8xi8>,
// CHECK-SAME:  %[[VAL_2:.*]]: vector<8xi32>) -> vector<8xi32> {
// CHECK:  %[[VAL_3:.*]] = arith.constant dense<0> : vector<2x2xi32>
// CHECK:  %[[VAL_4:.*]] = arith.constant dense<0> : vector<2x8xi8>
// CHECK:  %[[VAL_5:.*]] = arith.constant dense<0> : vector<8xi32>
// CHECK:  %[[VAL_6:.*]] = vector.extract_strided_slice %[[VAL_1]] {offsets = [0, 0], sizes = [2, 8], strides = [1, 1]} : vector<8x8xi8> to vector<2x8xi8>
// CHECK:  %[[VAL_7:.*]] = vector.extract_strided_slice %[[VAL_2]] {offsets = [0], sizes = [2], strides = [1]} : vector<8xi32> to vector<2xi32>
// CHECK:  %[[VAL_8:.*]] = vector.insert_strided_slice %[[VAL_0]], %[[VAL_4]] {offsets = [0, 0], strides = [1]} : vector<8xi8> into vector<2x8xi8>
// CHECK:  %[[VAL_9:.*]] = vector.insert_strided_slice %[[VAL_7]], %[[VAL_3]] {offsets = [0, 0], strides = [1]} : vector<2xi32> into vector<2x2xi32>
// CHECK:  %[[VAL_10:.*]] = vector.shape_cast %[[VAL_8]] : vector<2x8xi8> to vector<16xi8>
// CHECK:  %[[VAL_11:.*]] = vector.shape_cast %[[VAL_6]] : vector<2x8xi8> to vector<16xi8>
// CHECK:  %[[VAL_12:.*]] = vector.shape_cast %[[VAL_9]] : vector<2x2xi32> to vector<4xi32>
// CHECK:  %[[VAL_13:.*]] = arm_neon.intr.smmla %[[VAL_12]], %[[VAL_10]], %[[VAL_11]] : vector<16xi8> to vector<4xi32>
// CHECK:  %[[VAL_14:.*]] = vector.shape_cast %[[VAL_13]] : vector<4xi32> to vector<2x2xi32>
// CHECK:  %[[VAL_15:.*]] = vector.extract %[[VAL_14]][0] : vector<2xi32> from vector<2x2xi32>
// CHECK:  %[[VAL_16:.*]] = vector.insert_strided_slice %[[VAL_15]], %[[VAL_5]] {offsets = [0], strides = [1]} : vector<2xi32> into vector<8xi32>
// CHECK:  %[[VAL_17:.*]] = vector.extract_strided_slice %[[VAL_1]] {offsets = [2, 0], sizes = [2, 8], strides = [1, 1]} : vector<8x8xi8> to vector<2x8xi8>
// CHECK:  %[[VAL_18:.*]] = vector.extract_strided_slice %[[VAL_2]] {offsets = [2], sizes = [2], strides = [1]} : vector<8xi32> to vector<2xi32>
// CHECK:  %[[VAL_19:.*]] = vector.insert_strided_slice %[[VAL_0]], %[[VAL_4]] {offsets = [0, 0], strides = [1]} : vector<8xi8> into vector<2x8xi8>
// CHECK:  %[[VAL_20:.*]] = vector.insert_strided_slice %[[VAL_18]], %[[VAL_3]] {offsets = [0, 0], strides = [1]} : vector<2xi32> into vector<2x2xi32>
// CHECK:  %[[VAL_21:.*]] = vector.shape_cast %[[VAL_19]] : vector<2x8xi8> to vector<16xi8>
// CHECK:  %[[VAL_22:.*]] = vector.shape_cast %[[VAL_17]] : vector<2x8xi8> to vector<16xi8>
// CHECK:  %[[VAL_23:.*]] = vector.shape_cast %[[VAL_20]] : vector<2x2xi32> to vector<4xi32>
// CHECK:  %[[VAL_24:.*]] = arm_neon.intr.smmla %[[VAL_23]], %[[VAL_21]], %[[VAL_22]] : vector<16xi8> to vector<4xi32>
// CHECK:  %[[VAL_25:.*]] = vector.shape_cast %[[VAL_24]] : vector<4xi32> to vector<2x2xi32>
// CHECK:  %[[VAL_26:.*]] = vector.extract %[[VAL_25]][0] : vector<2xi32> from vector<2x2xi32>
// CHECK:  %[[VAL_27:.*]] = vector.insert_strided_slice %[[VAL_26]], %[[VAL_16]] {offsets = [2], strides = [1]} : vector<2xi32> into vector<8xi32>
// CHECK:  %[[VAL_28:.*]] = vector.extract_strided_slice %[[VAL_1]] {offsets = [4, 0], sizes = [2, 8], strides = [1, 1]} : vector<8x8xi8> to vector<2x8xi8>
// CHECK:  %[[VAL_29:.*]] = vector.extract_strided_slice %[[VAL_2]] {offsets = [4], sizes = [2], strides = [1]} : vector<8xi32> to vector<2xi32>
// CHECK:  %[[VAL_30:.*]] = vector.insert_strided_slice %[[VAL_0]], %[[VAL_4]] {offsets = [0, 0], strides = [1]} : vector<8xi8> into vector<2x8xi8>
// CHECK:  %[[VAL_31:.*]] = vector.insert_strided_slice %[[VAL_29]], %[[VAL_3]] {offsets = [0, 0], strides = [1]} : vector<2xi32> into vector<2x2xi32>
// CHECK:  %[[VAL_32:.*]] = vector.shape_cast %[[VAL_30]] : vector<2x8xi8> to vector<16xi8>
// CHECK:  %[[VAL_33:.*]] = vector.shape_cast %[[VAL_28]] : vector<2x8xi8> to vector<16xi8>
// CHECK:  %[[VAL_34:.*]] = vector.shape_cast %[[VAL_31]] : vector<2x2xi32> to vector<4xi32>
// CHECK:  %[[VAL_35:.*]] = arm_neon.intr.smmla %[[VAL_34]], %[[VAL_32]], %[[VAL_33]] : vector<16xi8> to vector<4xi32>
// CHECK:  %[[VAL_36:.*]] = vector.shape_cast %[[VAL_35]] : vector<4xi32> to vector<2x2xi32>
// CHECK:  %[[VAL_37:.*]] = vector.extract %[[VAL_36]][0] : vector<2xi32> from vector<2x2xi32>
// CHECK:  %[[VAL_38:.*]] = vector.insert_strided_slice %[[VAL_37]], %[[VAL_27]] {offsets = [4], strides = [1]} : vector<2xi32> into vector<8xi32>
// CHECK:  %[[VAL_39:.*]] = vector.extract_strided_slice %[[VAL_1]] {offsets = [6, 0], sizes = [2, 8], strides = [1, 1]} : vector<8x8xi8> to vector<2x8xi8>
// CHECK:  %[[VAL_40:.*]] = vector.extract_strided_slice %[[VAL_2]] {offsets = [6], sizes = [2], strides = [1]} : vector<8xi32> to vector<2xi32>
// CHECK:  %[[VAL_41:.*]] = vector.insert_strided_slice %[[VAL_0]], %[[VAL_4]] {offsets = [0, 0], strides = [1]} : vector<8xi8> into vector<2x8xi8>
// CHECK:  %[[VAL_42:.*]] = vector.insert_strided_slice %[[VAL_40]], %[[VAL_3]] {offsets = [0, 0], strides = [1]} : vector<2xi32> into vector<2x2xi32>
// CHECK:  %[[VAL_43:.*]] = vector.shape_cast %[[VAL_41]] : vector<2x8xi8> to vector<16xi8>
// CHECK:  %[[VAL_44:.*]] = vector.shape_cast %[[VAL_39]] : vector<2x8xi8> to vector<16xi8>
// CHECK:  %[[VAL_45:.*]] = vector.shape_cast %[[VAL_42]] : vector<2x2xi32> to vector<4xi32>
// CHECK:  %[[VAL_46:.*]] = arm_neon.intr.smmla %[[VAL_45]], %[[VAL_43]], %[[VAL_44]] : vector<16xi8> to vector<4xi32>
// CHECK:  %[[VAL_47:.*]] = vector.shape_cast %[[VAL_46]] : vector<4xi32> to vector<2x2xi32>
// CHECK:  %[[VAL_48:.*]] = vector.extract %[[VAL_47]][0] : vector<2xi32> from vector<2x2xi32>
// CHECK:  %[[VAL_49:.*]] = vector.insert_strided_slice %[[VAL_48]], %[[VAL_38]] {offsets = [6], strides = [1]} : vector<2xi32> into vector<8xi32>
// CHECK:  return %[[VAL_49]] : vector<8xi32>
// CHECK:  }
func.func @vector_arm_neon_vecmat_unroll(%lhs: vector<8xi8>, %rhs: vector<8x8xi8>, %acc : vector<8xi32>) -> vector<8xi32> {
  %lhs_extsi= arith.extsi %lhs : vector<8xi8> to vector<8xi32>
  %rhs_extsi = arith.extsi %rhs : vector<8x8xi8> to vector<8x8xi32>
  %res = vector.contract {indexing_maps = [affine_map<(d0, d1) -> (d1)>, affine_map<(d0, d1) -> (d0, d1)>, affine_map<(d0, d1) -> (d0)>], iterator_types = ["parallel", "reduction"], kind = #vector.kind<add>} %lhs_extsi, %rhs_extsi, %acc : vector<8xi32>, vector<8x8xi32> into vector<8xi32>
  return %res : vector<8xi32>
}

// -----

// CHECK-LABEL:   func.func @vector_arm_neon_vecmat_unroll_leading_dim(
// CHECK-SAME:  %[[VAL_0:.*]]: vector<1x8xi8>,
// CHECK-SAME:  %[[VAL_1:.*]]: vector<8x8xi8>,
// CHECK-SAME:  %[[VAL_2:.*]]: vector<1x8xi32>) -> vector<1x8xi32> {
// CHECK:  %[[VAL_3:.*]] = arith.constant dense<0> : vector<2x2xi32>
// CHECK:  %[[VAL_4:.*]] = arith.constant dense<0> : vector<2x8xi8>
// CHECK:  %[[VAL_5:.*]] = arith.constant dense<0> : vector<1x8xi32>
// CHECK:  %[[VAL_6:.*]] = vector.extract_strided_slice %[[VAL_1]] {offsets = [0, 0], sizes = [2, 8], strides = [1, 1]} : vector<8x8xi8> to vector<2x8xi8>
// CHECK:  %[[VAL_7:.*]] = vector.extract_strided_slice %[[VAL_2]] {offsets = [0, 0], sizes = [1, 2], strides = [1, 1]} : vector<1x8xi32> to vector<1x2xi32>
// CHECK:  %[[VAL_8:.*]] = vector.insert_strided_slice %[[VAL_0]], %[[VAL_4]] {offsets = [0, 0], strides = [1, 1]} : vector<1x8xi8> into vector<2x8xi8>
// CHECK:  %[[VAL_9:.*]] = vector.insert_strided_slice %[[VAL_7]], %[[VAL_3]] {offsets = [0, 0], strides = [1, 1]} : vector<1x2xi32> into vector<2x2xi32>
// CHECK:  %[[VAL_10:.*]] = vector.shape_cast %[[VAL_8]] : vector<2x8xi8> to vector<16xi8>
// CHECK:  %[[VAL_11:.*]] = vector.shape_cast %[[VAL_6]] : vector<2x8xi8> to vector<16xi8>
// CHECK:  %[[VAL_12:.*]] = vector.shape_cast %[[VAL_9]] : vector<2x2xi32> to vector<4xi32>
// CHECK:  %[[VAL_13:.*]] = arm_neon.intr.smmla %[[VAL_12]], %[[VAL_10]], %[[VAL_11]] : vector<16xi8> to vector<4xi32>
// CHECK:  %[[VAL_14:.*]] = vector.shape_cast %[[VAL_13]] : vector<4xi32> to vector<2x2xi32>
// CHECK:  %[[VAL_15:.*]] = vector.extract %[[VAL_14]][0] : vector<2xi32> from vector<2x2xi32>
// CHECK:  %[[VAL_16:.*]] = vector.insert_strided_slice %[[VAL_15]], %[[VAL_5]] {offsets = [0, 0], strides = [1]} : vector<2xi32> into vector<1x8xi32>
// CHECK:  %[[VAL_17:.*]] = vector.extract_strided_slice %[[VAL_1]] {offsets = [2, 0], sizes = [2, 8], strides = [1, 1]} : vector<8x8xi8> to vector<2x8xi8>
// CHECK:  %[[VAL_18:.*]] = vector.extract_strided_slice %[[VAL_2]] {offsets = [0, 2], sizes = [1, 2], strides = [1, 1]} : vector<1x8xi32> to vector<1x2xi32>
// CHECK:  %[[VAL_19:.*]] = vector.insert_strided_slice %[[VAL_0]], %[[VAL_4]] {offsets = [0, 0], strides = [1, 1]} : vector<1x8xi8> into vector<2x8xi8>
// CHECK:  %[[VAL_20:.*]] = vector.insert_strided_slice %[[VAL_18]], %[[VAL_3]] {offsets = [0, 0], strides = [1, 1]} : vector<1x2xi32> into vector<2x2xi32>
// CHECK:  %[[VAL_21:.*]] = vector.shape_cast %[[VAL_19]] : vector<2x8xi8> to vector<16xi8>
// CHECK:  %[[VAL_22:.*]] = vector.shape_cast %[[VAL_17]] : vector<2x8xi8> to vector<16xi8>
// CHECK:  %[[VAL_23:.*]] = vector.shape_cast %[[VAL_20]] : vector<2x2xi32> to vector<4xi32>
// CHECK:  %[[VAL_24:.*]] = arm_neon.intr.smmla %[[VAL_23]], %[[VAL_21]], %[[VAL_22]] : vector<16xi8> to vector<4xi32>
// CHECK:  %[[VAL_25:.*]] = vector.shape_cast %[[VAL_24]] : vector<4xi32> to vector<2x2xi32>
// CHECK:  %[[VAL_26:.*]] = vector.extract %[[VAL_25]][0] : vector<2xi32> from vector<2x2xi32>
// CHECK:  %[[VAL_27:.*]] = vector.insert_strided_slice %[[VAL_26]], %[[VAL_16]] {offsets = [0, 2], strides = [1]} : vector<2xi32> into vector<1x8xi32>
// CHECK:  %[[VAL_28:.*]] = vector.extract_strided_slice %[[VAL_1]] {offsets = [4, 0], sizes = [2, 8], strides = [1, 1]} : vector<8x8xi8> to vector<2x8xi8>
// CHECK:  %[[VAL_29:.*]] = vector.extract_strided_slice %[[VAL_2]] {offsets = [0, 4], sizes = [1, 2], strides = [1, 1]} : vector<1x8xi32> to vector<1x2xi32>
// CHECK:  %[[VAL_30:.*]] = vector.insert_strided_slice %[[VAL_0]], %[[VAL_4]] {offsets = [0, 0], strides = [1, 1]} : vector<1x8xi8> into vector<2x8xi8>
// CHECK:  %[[VAL_31:.*]] = vector.insert_strided_slice %[[VAL_29]], %[[VAL_3]] {offsets = [0, 0], strides = [1, 1]} : vector<1x2xi32> into vector<2x2xi32>
// CHECK:  %[[VAL_32:.*]] = vector.shape_cast %[[VAL_30]] : vector<2x8xi8> to vector<16xi8>
// CHECK:  %[[VAL_33:.*]] = vector.shape_cast %[[VAL_28]] : vector<2x8xi8> to vector<16xi8>
// CHECK:  %[[VAL_34:.*]] = vector.shape_cast %[[VAL_31]] : vector<2x2xi32> to vector<4xi32>
// CHECK:  %[[VAL_35:.*]] = arm_neon.intr.smmla %[[VAL_34]], %[[VAL_32]], %[[VAL_33]] : vector<16xi8> to vector<4xi32>
// CHECK:  %[[VAL_36:.*]] = vector.shape_cast %[[VAL_35]] : vector<4xi32> to vector<2x2xi32>
// CHECK:  %[[VAL_37:.*]] = vector.extract %[[VAL_36]][0] : vector<2xi32> from vector<2x2xi32>
// CHECK:  %[[VAL_38:.*]] = vector.insert_strided_slice %[[VAL_37]], %[[VAL_27]] {offsets = [0, 4], strides = [1]} : vector<2xi32> into vector<1x8xi32>
// CHECK:  %[[VAL_39:.*]] = vector.extract_strided_slice %[[VAL_1]] {offsets = [6, 0], sizes = [2, 8], strides = [1, 1]} : vector<8x8xi8> to vector<2x8xi8>
// CHECK:  %[[VAL_40:.*]] = vector.extract_strided_slice %[[VAL_2]] {offsets = [0, 6], sizes = [1, 2], strides = [1, 1]} : vector<1x8xi32> to vector<1x2xi32>
// CHECK:  %[[VAL_41:.*]] = vector.insert_strided_slice %[[VAL_0]], %[[VAL_4]] {offsets = [0, 0], strides = [1, 1]} : vector<1x8xi8> into vector<2x8xi8>
// CHECK:  %[[VAL_42:.*]] = vector.insert_strided_slice %[[VAL_40]], %[[VAL_3]] {offsets = [0, 0], strides = [1, 1]} : vector<1x2xi32> into vector<2x2xi32>
// CHECK:  %[[VAL_43:.*]] = vector.shape_cast %[[VAL_41]] : vector<2x8xi8> to vector<16xi8>
// CHECK:  %[[VAL_44:.*]] = vector.shape_cast %[[VAL_39]] : vector<2x8xi8> to vector<16xi8>
// CHECK:  %[[VAL_45:.*]] = vector.shape_cast %[[VAL_42]] : vector<2x2xi32> to vector<4xi32>
// CHECK:  %[[VAL_46:.*]] = arm_neon.intr.smmla %[[VAL_45]], %[[VAL_43]], %[[VAL_44]] : vector<16xi8> to vector<4xi32>
// CHECK:  %[[VAL_47:.*]] = vector.shape_cast %[[VAL_46]] : vector<4xi32> to vector<2x2xi32>
// CHECK:  %[[VAL_48:.*]] = vector.extract %[[VAL_47]][0] : vector<2xi32> from vector<2x2xi32>
// CHECK:  %[[VAL_49:.*]] = vector.insert_strided_slice %[[VAL_48]], %[[VAL_38]] {offsets = [0, 6], strides = [1]} : vector<2xi32> into vector<1x8xi32>
// CHECK:  return %[[VAL_49]] : vector<1x8xi32>
// CHECK:  }
func.func @vector_arm_neon_vecmat_unroll_leading_dim(%lhs: vector<1x8xi8>, %rhs: vector<8x8xi8>, %acc : vector<1x8xi32>) -> vector<1x8xi32> {
  %lhs_extsi= arith.extsi %lhs : vector<1x8xi8> to vector<1x8xi32>
  %rhs_extsi = arith.extsi %rhs : vector<8x8xi8> to vector<8x8xi32>
  %res = vector.contract {indexing_maps = [affine_map<(d0, d1, d2) -> (d0, d2)>, affine_map<(d0, d1, d2) -> (d1, d2)>, affine_map<(d0, d1, d2) -> (d0, d1)>], iterator_types = ["parallel", "parallel", "reduction"], kind = #vector.kind<add>} %lhs_extsi, %rhs_extsi, %acc : vector<1x8xi32>, vector<8x8xi32> into vector<1x8xi32>
  return %res : vector<1x8xi32>
}

// -----

// CHECK-LABEL: func.func @vector_arm_neon_matvec
// CHECK-NOT: arm_neon.intr.smmla
func.func @vector_arm_neon_matvec(%lhs: vector<8x8xi8>, %rhs: vector<8xi8>, %acc : vector<8xi32>) -> vector<8xi32> {
  %rhs_extsi= arith.extsi %rhs : vector<8xi8> to vector<8xi32>
  %lhs_extsi = arith.extsi %lhs : vector<8x8xi8> to vector<8x8xi32>
  %res = vector.contract {indexing_maps = [affine_map<(d0, d1) -> (d0, d1)>,affine_map<(d0, d1) -> (d1)>, affine_map<(d0, d1) -> (d0)>], iterator_types = ["parallel", "reduction"], kind = #vector.kind<add>} %lhs_extsi, %rhs_extsi, %acc : vector<8x8xi32>, vector<8xi32> into vector<8xi32>
  return %res : vector<8xi32>
}


// -----

// CHECK-LABEL:   func.func @vector_arm_neon_k_unroll(
// CHECK-SAME: %[[VAL_0:.*]]: vector<2x16xi8>,
// CHECK-SAME: %[[VAL_1:.*]]: vector<2x16xi4>,
// CHECK-SAME: %[[VAL_2:.*]]: vector<2x2xi32>) -> vector<2x2xi32> {
// CHECK:  %[[VAL_3:.*]] = arith.extsi %[[VAL_1]] : vector<2x16xi4> to vector<2x16xi8>
// CHECK:  %[[VAL_4:.*]] = vector.extract_strided_slice %[[VAL_0]] {offsets = [0, 0], sizes = [2, 8], strides = [1, 1]} : vector<2x16xi8> to vector<2x8xi8>
// CHECK:  %[[VAL_5:.*]] = vector.extract_strided_slice %[[VAL_3]] {offsets = [0, 0], sizes = [2, 8], strides = [1, 1]} : vector<2x16xi8> to vector<2x8xi8>
// CHECK:  %[[VAL_6:.*]] = vector.shape_cast %[[VAL_4]] : vector<2x8xi8> to vector<16xi8>
// CHECK:  %[[VAL_7:.*]] = vector.shape_cast %[[VAL_5]] : vector<2x8xi8> to vector<16xi8>
// CHECK:  %[[VAL_8:.*]] = vector.shape_cast %[[VAL_2]] : vector<2x2xi32> to vector<4xi32>
// CHECK:  %[[KACC_0:.*]] = arm_neon.intr.smmla %[[VAL_8]], %[[VAL_6]], %[[VAL_7]] : vector<16xi8> to vector<4xi32>
// CHECK:  %[[VAL_10:.*]] = vector.extract_strided_slice %[[VAL_0]] {offsets = [0, 8], sizes = [2, 8], strides = [1, 1]} : vector<2x16xi8> to vector<2x8xi8>
// CHECK:  %[[VAL_11:.*]] = vector.extract_strided_slice %[[VAL_3]] {offsets = [0, 8], sizes = [2, 8], strides = [1, 1]} : vector<2x16xi8> to vector<2x8xi8>
// CHECK:  %[[VAL_12:.*]] = vector.shape_cast %[[VAL_10]] : vector<2x8xi8> to vector<16xi8>
// CHECK:  %[[VAL_13:.*]] = vector.shape_cast %[[VAL_11]] : vector<2x8xi8> to vector<16xi8>
// CHECK:  %[[KACC_1:.*]] = arm_neon.intr.smmla %[[KACC_0]], %[[VAL_12]], %[[VAL_13]] : vector<16xi8> to vector<4xi32>
// CHECK:  %[[VAL_15:.*]] = vector.shape_cast %[[KACC_1]] : vector<4xi32> to vector<2x2xi32>
// CHECK:  return %[[VAL_15]] : vector<2x2xi32>
// CHECK:  }
func.func @vector_arm_neon_k_unroll(%lhs: vector<2x16xi8>, %rhs: vector<2x16xi4>, %acc : vector<2x2xi32>) -> vector<2x2xi32> {
  %lhs_extsi = arith.extsi %lhs : vector<2x16xi8> to vector<2x16xi32>
  %rhs_extsi = arith.extsi %rhs : vector<2x16xi4> to vector<2x16xi32>
  %res = vector.contract {indexing_maps = [affine_map<(d0, d1, d2) -> (d0, d2)>, affine_map<(d0, d1, d2) -> (d1, d2)>, affine_map<(d0, d1, d2) -> (d0, d1)>], iterator_types = ["parallel", "parallel", "reduction"], kind = #vector.kind<add>} %lhs_extsi, %rhs_extsi, %acc : vector<2x16xi32>, vector<2x16xi32> into vector<2x2xi32>
  return %res : vector<2x2xi32>
}

// -----

// CHECK-LABEL:   func.func @vector_arm_neon_k_unroll_vecmat(
// CHECK-SAME:                                               %[[VAL_0:.*]]: vector<1x32xi8>,
// CHECK-SAME:                                               %[[VAL_1:.*]]: vector<2x32xi4>,
// CHECK-SAME:                                               %[[VAL_2:.*]]: vector<1x2xi32>) -> vector<1x2xi32> {
// CHECK:  %[[VAL_3:.*]] = arith.constant dense<0> : vector<2x2xi32>
// CHECK:  %[[VAL_4:.*]] = arith.constant dense<0> : vector<2x8xi8>
// CHECK:  %[[VAL_5:.*]] = arith.constant dense<0> : vector<1x2xi32>
// CHECK:  %[[VAL_6:.*]] = arith.extsi %[[VAL_1]] : vector<2x32xi4> to vector<2x32xi8>
// CHECK:  %[[VAL_7:.*]] = vector.extract_strided_slice %[[VAL_0]] {offsets = [0, 0], sizes = [1, 8], strides = [1, 1]} : vector<1x32xi8> to vector<1x8xi8>
// CHECK:  %[[VAL_8:.*]] = vector.extract_strided_slice %[[VAL_6]] {offsets = [0, 0], sizes = [2, 8], strides = [1, 1]} : vector<2x32xi8> to vector<2x8xi8>
// CHECK:  %[[VAL_9:.*]] = vector.insert_strided_slice %[[VAL_7]], %[[VAL_4]] {offsets = [0, 0], strides = [1, 1]} : vector<1x8xi8> into vector<2x8xi8>
// CHECK:  %[[VAL_10:.*]] = vector.insert_strided_slice %[[VAL_2]], %[[VAL_3]] {offsets = [0, 0], strides = [1, 1]} : vector<1x2xi32> into vector<2x2xi32>
// CHECK:  %[[VAL_11:.*]] = vector.shape_cast %[[VAL_9]] : vector<2x8xi8> to vector<16xi8>
// CHECK:  %[[VAL_12:.*]] = vector.shape_cast %[[VAL_8]] : vector<2x8xi8> to vector<16xi8>
// CHECK:  %[[VAL_13:.*]] = vector.shape_cast %[[VAL_10]] : vector<2x2xi32> to vector<4xi32>
// CHECK:  %[[KACC_0:.*]] = arm_neon.intr.smmla %[[VAL_13]], %[[VAL_11]], %[[VAL_12]] : vector<16xi8> to vector<4xi32>
// CHECK:  %[[VAL_15:.*]] = vector.shape_cast %[[KACC_0]] : vector<4xi32> to vector<2x2xi32>
// CHECK:  %[[VAL_16:.*]] = vector.extract %[[VAL_15]][0] : vector<2xi32> from vector<2x2xi32>
// CHECK:  %[[VAL_17:.*]] = vector.insert_strided_slice %[[VAL_16]], %[[VAL_5]] {offsets = [0, 0], strides = [1]} : vector<2xi32> into vector<1x2xi32>
// CHECK:  %[[VAL_18:.*]] = vector.extract_strided_slice %[[VAL_0]] {offsets = [0, 8], sizes = [1, 8], strides = [1, 1]} : vector<1x32xi8> to vector<1x8xi8>
// CHECK:  %[[VAL_19:.*]] = vector.extract_strided_slice %[[VAL_6]] {offsets = [0, 8], sizes = [2, 8], strides = [1, 1]} : vector<2x32xi8> to vector<2x8xi8>
// CHECK:  %[[VAL_20:.*]] = vector.insert_strided_slice %[[VAL_18]], %[[VAL_4]] {offsets = [0, 0], strides = [1, 1]} : vector<1x8xi8> into vector<2x8xi8>
// CHECK:  %[[VAL_21:.*]] = vector.shape_cast %[[VAL_20]] : vector<2x8xi8> to vector<16xi8>
// CHECK:  %[[VAL_22:.*]] = vector.shape_cast %[[VAL_19]] : vector<2x8xi8> to vector<16xi8>
// CHECK:  %[[KACC_1:.*]] = arm_neon.intr.smmla %[[KACC_0]], %[[VAL_21]], %[[VAL_22]] : vector<16xi8> to vector<4xi32>
// CHECK:  %[[VAL_24:.*]] = vector.shape_cast %[[KACC_1]] : vector<4xi32> to vector<2x2xi32>
// CHECK:  %[[VAL_25:.*]] = vector.extract %[[VAL_24]][0] : vector<2xi32> from vector<2x2xi32>
// CHECK:  %[[VAL_26:.*]] = vector.insert_strided_slice %[[VAL_25]], %[[VAL_17]] {offsets = [0, 0], strides = [1]} : vector<2xi32> into vector<1x2xi32>
// CHECK:  %[[VAL_27:.*]] = vector.extract_strided_slice %[[VAL_0]] {offsets = [0, 16], sizes = [1, 8], strides = [1, 1]} : vector<1x32xi8> to vector<1x8xi8>
// CHECK:  %[[VAL_28:.*]] = vector.extract_strided_slice %[[VAL_6]] {offsets = [0, 16], sizes = [2, 8], strides = [1, 1]} : vector<2x32xi8> to vector<2x8xi8>
// CHECK:  %[[VAL_29:.*]] = vector.insert_strided_slice %[[VAL_27]], %[[VAL_4]] {offsets = [0, 0], strides = [1, 1]} : vector<1x8xi8> into vector<2x8xi8>
// CHECK:  %[[VAL_30:.*]] = vector.shape_cast %[[VAL_29]] : vector<2x8xi8> to vector<16xi8>
// CHECK:  %[[VAL_31:.*]] = vector.shape_cast %[[VAL_28]] : vector<2x8xi8> to vector<16xi8>
// CHECK:  %[[KACC_2:.*]] = arm_neon.intr.smmla %[[KACC_1]], %[[VAL_30]], %[[VAL_31]] : vector<16xi8> to vector<4xi32>
// CHECK:  %[[VAL_33:.*]] = vector.shape_cast %[[KACC_2]] : vector<4xi32> to vector<2x2xi32>
// CHECK:  %[[VAL_34:.*]] = vector.extract %[[VAL_33]][0] : vector<2xi32> from vector<2x2xi32>
// CHECK:  %[[VAL_35:.*]] = vector.insert_strided_slice %[[VAL_34]], %[[VAL_26]] {offsets = [0, 0], strides = [1]} : vector<2xi32> into vector<1x2xi32>
// CHECK:  %[[VAL_36:.*]] = vector.extract_strided_slice %[[VAL_0]] {offsets = [0, 24], sizes = [1, 8], strides = [1, 1]} : vector<1x32xi8> to vector<1x8xi8>
// CHECK:  %[[VAL_37:.*]] = vector.extract_strided_slice %[[VAL_6]] {offsets = [0, 24], sizes = [2, 8], strides = [1, 1]} : vector<2x32xi8> to vector<2x8xi8>
// CHECK:  %[[VAL_38:.*]] = vector.insert_strided_slice %[[VAL_36]], %[[VAL_4]] {offsets = [0, 0], strides = [1, 1]} : vector<1x8xi8> into vector<2x8xi8>
// CHECK:  %[[VAL_39:.*]] = vector.shape_cast %[[VAL_38]] : vector<2x8xi8> to vector<16xi8>
// CHECK:  %[[VAL_40:.*]] = vector.shape_cast %[[VAL_37]] : vector<2x8xi8> to vector<16xi8>
// CHECK:  %[[KACC_3:.*]] = arm_neon.intr.smmla %[[KACC_2]], %[[VAL_39]], %[[VAL_40]] : vector<16xi8> to vector<4xi32>
// CHECK:  %[[VAL_42:.*]] = vector.shape_cast %[[KACC_3]] : vector<4xi32> to vector<2x2xi32>
// CHECK:  %[[VAL_43:.*]] = vector.extract %[[VAL_42]][0] : vector<2xi32> from vector<2x2xi32>
// CHECK:  %[[VAL_44:.*]] = vector.insert_strided_slice %[[VAL_43]], %[[VAL_35]] {offsets = [0, 0], strides = [1]} : vector<2xi32> into vector<1x2xi32>
// CHECK:  return %[[VAL_44]] : vector<1x2xi32>
func.func @vector_arm_neon_k_unroll_vecmat(%lhs: vector<1x32xi8>, %rhs: vector<2x32xi4>, %acc : vector<1x2xi32>) -> vector<1x2xi32> {
  %lhs_extsi = arith.extsi %lhs : vector<1x32xi8> to vector<1x32xi32>
  %rhs_extsi = arith.extsi %rhs : vector<2x32xi4> to vector<2x32xi32>
  %res = vector.contract {indexing_maps = [affine_map<(d0, d1, d2) -> (d0, d2)>, affine_map<(d0, d1, d2) -> (d1, d2)>, affine_map<(d0, d1, d2) -> (d0, d1)>], iterator_types = ["parallel", "parallel", "reduction"], kind = #vector.kind<add>} %lhs_extsi, %rhs_extsi, %acc : vector<1x32xi32>, vector<2x32xi32> into vector<1x2xi32>
  return %res : vector<1x2xi32>
}

// -----

// Test with more than one iteration across all of the M, N and K dimensions.
// Shows multiple independent accumulators as well as accumulator reuse.
// For each iterarion [I, J, K] sub-tiles are extracted from offsets as follows:
//   LHS: [2*I, 8*K]
//   RHS: [2*J, 8*K]
//   ACC: [2*I, 2*J]
// Sub-tile insert offsets for the result are as like ACC (there are redundant
// inserts).

// CHECK-LABEL: @vector_arm_neon_mnk_unroll
// CHECK-SAME:    %[[LHS:arg0]]: vector<4x16xi8>
// CHECK-SAME:    %[[RHS:arg1]]: vector<4x16xi8>
// CHECK-SAME:    %[[ACC:arg2]]: vector<4x4xi32>
// CHECK-SAME:    -> vector<4x4xi32> {
// CHECK-NEXT:  %cst = arith.constant dense<0> : vector<4x4xi32>

// Iteration: [0, 0, 0]
// CHECK-NEXT:  %[[VAL_0:[0-9]+]] = vector.extract_strided_slice %[[LHS]] {offsets = [0, 0], sizes = [2, 8], strides = [1, 1]} : vector<4x16xi8> to vector<2x8xi8>
// CHECK-NEXT:  %[[VAL_1:[0-9]+]] = vector.extract_strided_slice %[[RHS]] {offsets = [0, 0], sizes = [2, 8], strides = [1, 1]} : vector<4x16xi8> to vector<2x8xi8>
// CHECK-NEXT:  %[[VAL_2:[0-9]+]] = vector.extract_strided_slice %[[ACC]] {offsets = [0, 0], sizes = [2, 2], strides = [1, 1]} : vector<4x4xi32> to vector<2x2xi32>
// CHECK-NEXT:  %[[VAL_3:[0-9]+]] = vector.shape_cast %[[VAL_0]] : vector<2x8xi8> to vector<16xi8>
// CHECK-NEXT:  %[[VAL_4:[0-9]+]] = vector.shape_cast %[[VAL_1]] : vector<2x8xi8> to vector<16xi8>
// CHECK-NEXT:  %[[VAL_5:[0-9]+]] = vector.shape_cast %[[VAL_2]] : vector<2x2xi32> to vector<4xi32>
// CHECK-NEXT:  %[[KACC_0_v0:[0-9]+]] = arm_neon.intr.smmla %[[VAL_5]], %[[VAL_3]], %[[VAL_4]] : vector<16xi8> to vector<4xi32>
// CHECK-NEXT:  %[[VAL_7:[0-9]+]] = vector.shape_cast %[[KACC_0_v0]] : vector<4xi32> to vector<2x2xi32>
// CHECK-NEXT:  %[[VAL_8:[0-9]+]] = vector.insert_strided_slice %[[VAL_7]], %cst {offsets = [0, 0], strides = [1, 1]} : vector<2x2xi32> into vector<4x4xi32>

// Iteration: [0, 0, 1]
// CHECK-NEXT:  %[[VAL_9:[0-9]+]] = vector.extract_strided_slice %[[LHS]] {offsets = [0, 8], sizes = [2, 8], strides = [1, 1]} : vector<4x16xi8> to vector<2x8xi8>
// CHECK-NEXT:  %[[VAL_10:[0-9]+]] = vector.extract_strided_slice %[[RHS]] {offsets = [0, 8], sizes = [2, 8], strides = [1, 1]} : vector<4x16xi8> to vector<2x8xi8>
// CHECK-NEXT:  %[[VAL_11:[0-9]+]] = vector.shape_cast %[[VAL_9]] : vector<2x8xi8> to vector<16xi8>
// CHECK-NEXT:  %[[VAL_12:[0-9]+]] = vector.shape_cast %[[VAL_10]] : vector<2x8xi8> to vector<16xi8>
// CHECK-NEXT:  %[[KACC_0_v1:[0-9]+]] = arm_neon.intr.smmla %[[KACC_0_v0]], %[[VAL_11]], %[[VAL_12]] : vector<16xi8> to vector<4xi32>
// CHECK-NEXT:  %[[VAL_14:[0-9]+]] = vector.shape_cast %[[KACC_0_v1]] : vector<4xi32> to vector<2x2xi32>
// CHECK-NEXT:  %[[VAL_15:[0-9]+]] = vector.insert_strided_slice %[[VAL_14]], %[[VAL_8]] {offsets = [0, 0], strides = [1, 1]} : vector<2x2xi32> into vector<4x4xi32>

// Iteration: [0, 1, 0]
// CHECK-NEXT:  %[[VAL_16:[0-9]+]] = vector.extract_strided_slice %[[LHS]] {offsets = [0, 0], sizes = [2, 8], strides = [1, 1]} : vector<4x16xi8> to vector<2x8xi8>
// CHECK-NEXT:  %[[VAL_17:[0-9]+]] = vector.extract_strided_slice %[[RHS]] {offsets = [2, 0], sizes = [2, 8], strides = [1, 1]} : vector<4x16xi8> to vector<2x8xi8>
// CHECK-NEXT:  %[[VAL_18:[0-9]+]] = vector.extract_strided_slice %[[ACC]] {offsets = [0, 2], sizes = [2, 2], strides = [1, 1]} : vector<4x4xi32> to vector<2x2xi32>
// CHECK-NEXT:  %[[VAL_19:[0-9]+]] = vector.shape_cast %[[VAL_16]] : vector<2x8xi8> to vector<16xi8>
// CHECK-NEXT:  %[[VAL_20:[0-9]+]] = vector.shape_cast %[[VAL_17]] : vector<2x8xi8> to vector<16xi8>
// CHECK-NEXT:  %[[VAL_21:[0-9]+]] = vector.shape_cast %[[VAL_18]] : vector<2x2xi32> to vector<4xi32>
// CHECK-NEXT:  %[[KACC_1_v0:[0-9]+]] = arm_neon.intr.smmla %[[VAL_21]], %[[VAL_19]], %[[VAL_20]] : vector<16xi8> to vector<4xi32>
// CHECK-NEXT:  %[[VAL_23:[0-9]+]] = vector.shape_cast %[[KACC_1_v0]] : vector<4xi32> to vector<2x2xi32>
// CHECK-NEXT:  %[[VAL_24:[0-9]+]] = vector.insert_strided_slice %[[VAL_23]], %[[VAL_15]] {offsets = [0, 2], strides = [1, 1]} : vector<2x2xi32> into vector<4x4xi32>

// Iteration: [0, 1, 1]
// CHECK-NEXT:  %[[VAL_25:[0-9]+]] = vector.extract_strided_slice %[[LHS]] {offsets = [0, 8], sizes = [2, 8], strides = [1, 1]} : vector<4x16xi8> to vector<2x8xi8>
// CHECK-NEXT:  %[[VAL_26:[0-9]+]] = vector.extract_strided_slice %[[RHS]] {offsets = [2, 8], sizes = [2, 8], strides = [1, 1]} : vector<4x16xi8> to vector<2x8xi8>
// CHECK-NEXT:  %[[VAL_27:[0-9]+]] = vector.shape_cast %[[VAL_25]] : vector<2x8xi8> to vector<16xi8>
// CHECK-NEXT:  %[[VAL_28:[0-9]+]] = vector.shape_cast %[[VAL_26]] : vector<2x8xi8> to vector<16xi8>
// CHECK-NEXT:  %[[KACC_1_v1:[0-9]+]] = arm_neon.intr.smmla %[[KACC_1_v0]], %[[VAL_27]], %[[VAL_28]] : vector<16xi8> to vector<4xi32>
// CHECK-NEXT:  %[[VAL_30:[0-9]+]] = vector.shape_cast %[[KACC_1_v1]] : vector<4xi32> to vector<2x2xi32>
// CHECK-NEXT:  %[[VAL_31:[0-9]+]] = vector.insert_strided_slice %[[VAL_30]], %[[VAL_24]] {offsets = [0, 2], strides = [1, 1]} : vector<2x2xi32> into vector<4x4xi32>

// Iteration: [1, 0, 0]
// CHECK-NEXT:  %[[VAL_32:[0-9]+]] = vector.extract_strided_slice %[[LHS]] {offsets = [2, 0], sizes = [2, 8], strides = [1, 1]} : vector<4x16xi8> to vector<2x8xi8>
// CHECK-NEXT:  %[[VAL_33:[0-9]+]] = vector.extract_strided_slice %[[RHS]] {offsets = [0, 0], sizes = [2, 8], strides = [1, 1]} : vector<4x16xi8> to vector<2x8xi8>
// CHECK-NEXT:  %[[VAL_34:[0-9]+]] = vector.extract_strided_slice %[[ACC]] {offsets = [2, 0], sizes = [2, 2], strides = [1, 1]} : vector<4x4xi32> to vector<2x2xi32>
// CHECK-NEXT:  %[[VAL_35:[0-9]+]] = vector.shape_cast %[[VAL_32]] : vector<2x8xi8> to vector<16xi8>
// CHECK-NEXT:  %[[VAL_36:[0-9]+]] = vector.shape_cast %[[VAL_33]] : vector<2x8xi8> to vector<16xi8>
// CHECK-NEXT:  %[[VAL_37:[0-9]+]] = vector.shape_cast %[[VAL_34]] : vector<2x2xi32> to vector<4xi32>
// CHECK-NEXT:  %[[KACC_2_v0:[0-9]+]] = arm_neon.intr.smmla %[[VAL_37]], %[[VAL_35]], %[[VAL_36]] : vector<16xi8> to vector<4xi32>
// CHECK-NEXT:  %[[VAL_39:[0-9]+]] = vector.shape_cast %[[KACC_2_v0]] : vector<4xi32> to vector<2x2xi32>
// CHECK-NEXT:  %[[VAL_40:[0-9]+]] = vector.insert_strided_slice %[[VAL_39]], %[[VAL_31]] {offsets = [2, 0], strides = [1, 1]} : vector<2x2xi32> into vector<4x4xi32>

// Iteration: [1, 0, 1]
// CHECK-NEXT:  %[[VAL_41:[0-9]+]] = vector.extract_strided_slice %[[LHS]] {offsets = [2, 8], sizes = [2, 8], strides = [1, 1]} : vector<4x16xi8> to vector<2x8xi8>
// CHECK-NEXT:  %[[VAL_42:[0-9]+]] = vector.extract_strided_slice %[[RHS]] {offsets = [0, 8], sizes = [2, 8], strides = [1, 1]} : vector<4x16xi8> to vector<2x8xi8>
// CHECK-NEXT:  %[[VAL_43:[0-9]+]] = vector.shape_cast %[[VAL_41]] : vector<2x8xi8> to vector<16xi8>
// CHECK-NEXT:  %[[VAL_44:[0-9]+]] = vector.shape_cast %[[VAL_42]] : vector<2x8xi8> to vector<16xi8>
// CHECK-NEXT:  %[[KACC_2_v1:[0-9]+]] = arm_neon.intr.smmla %[[KACC_2_v0]], %[[VAL_43]], %[[VAL_44]] : vector<16xi8> to vector<4xi32>
// CHECK-NEXT:  %[[VAL_46:[0-9]+]] = vector.shape_cast %[[KACC_2_v1]] : vector<4xi32> to vector<2x2xi32>
// CHECK-NEXT:  %[[VAL_47:[0-9]+]] = vector.insert_strided_slice %[[VAL_46]], %[[VAL_40]] {offsets = [2, 0], strides = [1, 1]} : vector<2x2xi32> into vector<4x4xi32>

// Iteration: [1, 1, 0]
// CHECK-NEXT:  %[[VAL_48:[0-9]+]] = vector.extract_strided_slice %[[LHS]] {offsets = [2, 0], sizes = [2, 8], strides = [1, 1]} : vector<4x16xi8> to vector<2x8xi8>
// CHECK-NEXT:  %[[VAL_49:[0-9]+]] = vector.extract_strided_slice %[[RHS]] {offsets = [2, 0], sizes = [2, 8], strides = [1, 1]} : vector<4x16xi8> to vector<2x8xi8>
// CHECK-NEXT:  %[[VAL_50:[0-9]+]] = vector.extract_strided_slice %[[ACC]] {offsets = [2, 2], sizes = [2, 2], strides = [1, 1]} : vector<4x4xi32> to vector<2x2xi32>
// CHECK-NEXT:  %[[VAL_51:[0-9]+]] = vector.shape_cast %[[VAL_48]] : vector<2x8xi8> to vector<16xi8>
// CHECK-NEXT:  %[[VAL_52:[0-9]+]] = vector.shape_cast %[[VAL_49]] : vector<2x8xi8> to vector<16xi8>
// CHECK-NEXT:  %[[VAL_53:[0-9]+]] = vector.shape_cast %[[VAL_50]] : vector<2x2xi32> to vector<4xi32>
// CHECK-NEXT:  %[[KACC_3_v0:[0-9]+]] = arm_neon.intr.smmla %[[VAL_53]], %[[VAL_51]], %[[VAL_52]] : vector<16xi8> to vector<4xi32>
// CHECK-NEXT:  %[[VAL_55:[0-9]+]] = vector.shape_cast %[[KACC_3_v0]] : vector<4xi32> to vector<2x2xi32>
// CHECK-NEXT:  %[[VAL_56:[0-9]+]] = vector.insert_strided_slice %[[VAL_55]], %[[VAL_47]] {offsets = [2, 2], strides = [1, 1]} : vector<2x2xi32> into vector<4x4xi32>

// Iteration: [1, 1, 1]
// CHECK-NEXT:  %[[VAL_57:[0-9]+]] = vector.extract_strided_slice %[[LHS]] {offsets = [2, 8], sizes = [2, 8], strides = [1, 1]} : vector<4x16xi8> to vector<2x8xi8>
// CHECK-NEXT:  %[[VAL_58:[0-9]+]] = vector.extract_strided_slice %[[RHS]] {offsets = [2, 8], sizes = [2, 8], strides = [1, 1]} : vector<4x16xi8> to vector<2x8xi8>
// CHECK-NEXT:  %[[VAL_59:[0-9]+]] = vector.shape_cast %[[VAL_57]] : vector<2x8xi8> to vector<16xi8>
// CHECK-NEXT:  %[[VAL_60:[0-9]+]] = vector.shape_cast %[[VAL_58]] : vector<2x8xi8> to vector<16xi8>
// CHECK-NEXT:  %[[KACC_3_v1:[0-9]+]] = arm_neon.intr.smmla %[[KACC_3_v0]], %[[VAL_59]], %[[VAL_60]] : vector<16xi8> to vector<4xi32>
// CHECK-NEXT:  %[[VAL_62:[0-9]+]] = vector.shape_cast %[[KACC_3_v1]] : vector<4xi32> to vector<2x2xi32>
// CHECK-NEXT:  %[[VAL_63:[0-9]+]] = vector.insert_strided_slice %[[VAL_62]], %[[VAL_56]] {offsets = [2, 2], strides = [1, 1]} : vector<2x2xi32> into vector<4x4xi32>

// CHECK-NEXT:  return %[[VAL_63]] : vector<4x4xi32>
func.func @vector_arm_neon_mnk_unroll(%lhs: vector<4x16xi8>, %rhs: vector<4x16xi8>, %acc : vector<4x4xi32>) -> vector<4x4xi32> {
  %lhs_extsi = arith.extsi %lhs : vector<4x16xi8> to vector<4x16xi32>
  %rhs_extsi = arith.extsi %rhs : vector<4x16xi8> to vector<4x16xi32>
  %res = vector.contract {indexing_maps = [affine_map<(d0, d1, d2) -> (d0, d2)>, affine_map<(d0, d1, d2) -> (d1, d2)>, affine_map<(d0, d1, d2) -> (d0, d1)>], iterator_types = ["parallel", "parallel", "reduction"], kind = #vector.kind<add>} %lhs_extsi, %rhs_extsi, %acc : vector<4x16xi32>, vector<4x16xi32> into vector<4x4xi32>
  return %res : vector<4x4xi32>
}

module attributes {transform.with_named_sequence} {
  transform.named_sequence @__transform_main(%module: !transform.any_op {transform.readonly}) {
    %func = transform.structured.match ops{["func.func"]} in %module : (!transform.any_op) -> !transform.op<"func.func">

    transform.apply_patterns to %func {
      transform.apply_patterns.arm_neon.vector_contract_to_i8mm
    } : !transform.op<"func.func">

    transform.yield
  }
}
