import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';
import { COLORS } from '../constants/colors';

// Fracciones de combustible comunes
const FUEL_FRACTIONS = [
  { value: 'RESERVA', decimal: 0.0, label: '0' },
  { value: '1/8', decimal: 0.125, label: '⅛' },
  { value: '1/4', decimal: 0.25, label: '¼' },
  { value: '3/8', decimal: 0.375, label: '⅜' },
  { value: '1/2', decimal: 0.5, label: '½' },
  { value: '5/8', decimal: 0.625, label: '⅝' },
  { value: '3/4', decimal: 0.75, label: '¾' },
  { value: '7/8', decimal: 0.875, label: '⅞' },
  { value: 'LLENO', decimal: 1.0, label: 'Lleno' },
];

interface FuelSelectorProps {
  value: string | null;
  onChange: (fraction: string, decimal: number) => void;
  label?: string;
  required?: boolean;
}

export default function FuelSelector({
  value,
  onChange,
  label = 'Nivel de Combustible',
  required = false
}: FuelSelectorProps) {
  return (
    <View style={styles.container}>
      <Text style={styles.label}>
        {label}
        {required && <Text style={styles.required}> *</Text>}
      </Text>

      <View style={styles.fractionsGrid}>
        {FUEL_FRACTIONS.map((fraction) => {
          const isSelected = value === fraction.value;

          return (
            <TouchableOpacity
              key={fraction.value}
              style={[
                styles.fractionButton,
                isSelected && styles.fractionButtonSelected,
              ]}
              onPress={() => onChange(fraction.value, fraction.decimal)}
            >
              <Text
                style={[
                  styles.fractionLabel,
                  isSelected && styles.fractionLabelSelected,
                ]}
              >
                {fraction.label}
              </Text>
              {fraction.value !== 'LLENO' && (
                <Text
                  style={[
                    styles.fractionValue,
                    isSelected && styles.fractionValueSelected,
                  ]}
                >
                  {fraction.value}
                </Text>
              )}
            </TouchableOpacity>
          );
        })}
      </View>

      {value && (
        <View style={styles.selectedInfo}>
          <Text style={styles.selectedText}>
            Seleccionado: {value} (
            {(FUEL_FRACTIONS.find(f => f.value === value)?.decimal || 0) * 100}% del tanque)
          </Text>
        </View>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    marginVertical: 8,
  },
  label: {
    fontSize: 14,
    fontWeight: '500',
    color: COLORS.text.primary,
    marginBottom: 12,
  },
  required: {
    color: COLORS.danger,
  },
  fractionsGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
  },
  fractionButton: {
    width: '22%',
    aspectRatio: 1,
    backgroundColor: COLORS.background,
    borderWidth: 2,
    borderColor: COLORS.border,
    borderRadius: 12,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 8,
  },
  fractionButtonSelected: {
    backgroundColor: COLORS.primary,
    borderColor: COLORS.primary,
  },
  fractionLabel: {
    fontSize: 24,
    fontWeight: '600',
    color: COLORS.text.primary,
  },
  fractionLabelSelected: {
    color: COLORS.white,
  },
  fractionValue: {
    fontSize: 11,
    color: COLORS.text.secondary,
    marginTop: 2,
  },
  fractionValueSelected: {
    color: COLORS.white,
    opacity: 0.9,
  },
  selectedInfo: {
    marginTop: 12,
    padding: 12,
    backgroundColor: COLORS.info + '20',
    borderRadius: 8,
  },
  selectedText: {
    fontSize: 13,
    color: COLORS.info,
    fontWeight: '500',
  },
});
