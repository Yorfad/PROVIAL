import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { Picker } from '@react-native-picker/picker';

interface Props {
  value?: string; // Formato: "HH:mm" (ej: "14:30")
  onChange: (value: string) => void;
  label?: string;
  required?: boolean;
}

/**
 * Genera opciones de hora en intervalos de 15 minutos
 * Desde 00:00 hasta 23:45
 */
const generateTimeOptions = (): string[] => {
  const options: string[] = [];

  for (let hour = 0; hour < 24; hour++) {
    for (let minute = 0; minute < 60; minute += 15) {
      const hourStr = hour.toString().padStart(2, '0');
      const minuteStr = minute.toString().padStart(2, '0');
      options.push(`${hourStr}:${minuteStr}`);
    }
  }

  return options;
};

const TIME_OPTIONS = generateTimeOptions();

export const HourSelect: React.FC<Props> = ({
  value,
  onChange,
  label = 'Hora',
  required = false,
}) => {
  return (
    <View style={styles.container}>
      <Text style={styles.label}>
        {label}
        {required && <Text style={styles.required}> *</Text>}
      </Text>

      <View style={styles.pickerContainer}>
        <Picker
          selectedValue={value || ''}
          onValueChange={(itemValue) => {
            if (itemValue !== '') {
              onChange(itemValue);
            }
          }}
          style={styles.picker}
        >
          <Picker.Item label="Seleccionar hora..." value="" />
          {TIME_OPTIONS.map((time) => (
            <Picker.Item key={time} label={time} value={time} />
          ))}
        </Picker>
      </View>

      {value && (
        <Text style={styles.selectedText}>Hora seleccionada: {value}</Text>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    marginBottom: 10,
  },
  label: {
    fontSize: 14,
    fontWeight: '600',
    color: '#333',
    marginBottom: 6,
  },
  required: {
    color: '#d32f2f',
  },
  pickerContainer: {
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 5,
    backgroundColor: '#fff',
  },
  picker: {
    height: 50,
  },
  selectedText: {
    marginTop: 4,
    fontSize: 12,
    color: '#666',
    fontStyle: 'italic',
  },
});
