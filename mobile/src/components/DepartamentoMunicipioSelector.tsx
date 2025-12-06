import React, { useEffect, useState } from 'react';
import { View, Text, StyleSheet, ActivityIndicator } from 'react-native';
import { Picker } from '@react-native-picker/picker';
import { geografiaAPI } from '../services/api';

interface Departamento {
  id: number;
  codigo: string;
  nombre: string;
}

interface Municipio {
  id: number;
  codigo: string;
  nombre: string;
  departamento_id: number;
}

interface Props {
  departamentoValue?: number;
  municipioValue?: number;
  onDepartamentoChange: (departamentoId: number | undefined) => void;
  onMunicipioChange: (municipioId: number | undefined) => void;
  departamentoLabel?: string;
  municipioLabel?: string;
  required?: boolean;
}

export const DepartamentoMunicipioSelector: React.FC<Props> = ({
  departamentoValue,
  municipioValue,
  onDepartamentoChange,
  onMunicipioChange,
  departamentoLabel = 'Departamento',
  municipioLabel = 'Municipio',
  required = false,
}) => {
  const [departamentos, setDepartamentos] = useState<Departamento[]>([]);
  const [municipios, setMunicipios] = useState<Municipio[]>([]);
  const [loadingDepartamentos, setLoadingDepartamentos] = useState(true);
  const [loadingMunicipios, setLoadingMunicipios] = useState(false);

  useEffect(() => {
    loadDepartamentos();
  }, []);

  useEffect(() => {
    if (departamentoValue) {
      loadMunicipios(departamentoValue);
    } else {
      setMunicipios([]);
      onMunicipioChange(undefined);
    }
  }, [departamentoValue]);

  const loadDepartamentos = async () => {
    try {
      setLoadingDepartamentos(true);
      const data = await geografiaAPI.getDepartamentos();
      setDepartamentos(data);
    } catch (error) {
      console.error('[DepartamentoMunicipioSelector] Error al cargar departamentos:', error);
    } finally {
      setLoadingDepartamentos(false);
    }
  };

  const loadMunicipios = async (departamentoId: number) => {
    try {
      setLoadingMunicipios(true);
      const data = await geografiaAPI.getMunicipiosPorDepartamento(departamentoId);
      setMunicipios(data);
    } catch (error) {
      console.error('[DepartamentoMunicipioSelector] Error al cargar municipios:', error);
      setMunicipios([]);
    } finally {
      setLoadingMunicipios(false);
    }
  };

  const handleDepartamentoChange = (value: string) => {
    if (value === '') {
      onDepartamentoChange(undefined);
    } else {
      onDepartamentoChange(parseInt(value, 10));
    }
  };

  const handleMunicipioChange = (value: string) => {
    if (value === '') {
      onMunicipioChange(undefined);
    } else {
      onMunicipioChange(parseInt(value, 10));
    }
  };

  return (
    <View style={styles.container}>
      {/* Selector de Departamento */}
      <View style={styles.selectorContainer}>
        <Text style={styles.label}>
          {departamentoLabel}
          {required && <Text style={styles.required}> *</Text>}
        </Text>

        {loadingDepartamentos ? (
          <View style={styles.loadingContainer}>
            <ActivityIndicator size="small" />
            <Text style={styles.loadingText}>Cargando departamentos...</Text>
          </View>
        ) : (
          <View style={styles.pickerContainer}>
            <Picker
              selectedValue={departamentoValue?.toString() || ''}
              onValueChange={handleDepartamentoChange}
              style={styles.picker}
            >
              <Picker.Item label="Seleccionar departamento..." value="" />
              {departamentos.map((depto) => (
                <Picker.Item
                  key={depto.id}
                  label={depto.nombre}
                  value={depto.id.toString()}
                />
              ))}
            </Picker>
          </View>
        )}
      </View>

      {/* Selector de Municipio (solo visible si hay departamento seleccionado) */}
      {departamentoValue && (
        <View style={styles.selectorContainer}>
          <Text style={styles.label}>
            {municipioLabel}
            {required && <Text style={styles.required}> *</Text>}
          </Text>

          {loadingMunicipios ? (
            <View style={styles.loadingContainer}>
              <ActivityIndicator size="small" />
              <Text style={styles.loadingText}>Cargando municipios...</Text>
            </View>
          ) : municipios.length > 0 ? (
            <View style={styles.pickerContainer}>
              <Picker
                selectedValue={municipioValue?.toString() || ''}
                onValueChange={handleMunicipioChange}
                style={styles.picker}
              >
                <Picker.Item label="Seleccionar municipio..." value="" />
                {municipios.map((municipio) => (
                  <Picker.Item
                    key={municipio.id}
                    label={municipio.nombre}
                    value={municipio.id.toString()}
                  />
                ))}
              </Picker>
            </View>
          ) : (
            <View style={styles.emptyContainer}>
              <Text style={styles.emptyText}>No hay municipios disponibles</Text>
            </View>
          )}
        </View>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    marginBottom: 10,
  },
  selectorContainer: {
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
  loadingContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 12,
    backgroundColor: '#f5f5f5',
    borderRadius: 5,
  },
  loadingText: {
    marginLeft: 8,
    fontSize: 14,
    color: '#666',
  },
  emptyContainer: {
    padding: 12,
    backgroundColor: '#f5f5f5',
    borderRadius: 5,
    borderWidth: 1,
    borderColor: '#ddd',
  },
  emptyText: {
    fontSize: 14,
    color: '#999',
    textAlign: 'center',
  },
});
