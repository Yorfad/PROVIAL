import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { COLORS } from '../constants/colors';

const OPCIONES_COMBUSTIBLE = [
  { label: 'Vacío', value: 'VACIO', decimal: 0 },
  { label: '1/8', value: '1/8', decimal: 0.125 },
  { label: '1/4', value: '1/4', decimal: 0.25 },
  { label: '3/8', value: '3/8', decimal: 0.375 },
  { label: '1/2', value: '1/2', decimal: 0.5 },
  { label: '5/8', value: '5/8', decimal: 0.625 },
  { label: '3/4', value: '3/4', decimal: 0.75 },
  { label: '7/8', value: '7/8', decimal: 0.875 },
  { label: 'Lleno', value: 'LLENO', decimal: 1 },
];

interface Props {
  value?: string;
  onChange: (fraccion: string, decimal: number) => void;
  label?: string;
  required?: boolean;
}

export default function CombustibleSelector({ value, onChange, label = 'Combustible', required = false }: Props) {
  return (
    <View style={styles.container}>
      <Text style={styles.label}>
        {label}
        {required && <Text style={styles.required}> *</Text>}
      </Text>

      <View style={styles.grid}>
        {OPCIONES_COMBUSTIBLE.map((opcion) => {
          const isSelected = value === opcion.value;

          return (
            <TouchableOpacity
              key={opcion.value}
              style={[
                styles.option,
                isSelected && styles.optionSelected,
              ]}
              onPress={() => onChange(opcion.value, opcion.decimal)}
            >
              <Text
                style={[
                  styles.optionText,
                  isSelected && styles.optionTextSelected,
                ]}
              >
                {opcion.label}
              </Text>
            </TouchableOpacity>
          );
        })}
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    marginBottom: 16,
  },
  label: {
    fontSize: 14,
    fontWeight: '600',
    color: COLORS.text.primary,
    marginBottom: 8,
  },
  required: {
    color: COLORS.danger,
  },
  grid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
  },
  option: {
    flex: 0,
    minWidth: '30%',
    paddingVertical: 12,
    paddingHorizontal: 16,
    backgroundColor: COLORS.white,
    borderWidth: 2,
    borderColor: COLORS.border,
    borderRadius: 8,
    alignItems: 'center',
  },
  optionSelected: {
    backgroundColor: COLORS.primary,
    borderColor: COLORS.primary,
  },
  optionText: {
    fontSize: 14,
    fontWeight: '600',
    color: COLORS.text.primary,
  },
  optionTextSelected: {
    color: COLORS.white,
  },
});
