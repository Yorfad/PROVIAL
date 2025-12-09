import React, { useEffect, useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  ActivityIndicator,
  RefreshControl
} from 'react-native';
import {
  Card,
  Title,
  Paragraph,
  Chip,
  Divider,
  List,
  Badge,
  Surface
} from 'react-native-paper';
import { useRoute, RouteProp } from '@react-navigation/native';
import { api } from '../../services/api';

type RouteParams = {
  VehiculoHistorial: {
    placa: string;
  };
};

interface Incidente {
  incidente_id: number;
  fecha: string;
  tipo_hecho: string;
  km: number;
  ruta_codigo: string;
  ruta_nombre: string;
  municipio: string;
  estado_piloto: string;
  cantidad_heridos: number;
  cantidad_fallecidos: number;
}

interface VehiculoHistorial {
  id: number;
  placa: string;
  es_extranjero: boolean;
  tipo_vehiculo: string;
  marca: string;
  color: string;
  total_incidentes: number;
  primer_incidente: string;
  ultimo_incidente: string;
  dias_desde_primer_incidente: number;
  dias_desde_ultimo_incidente: number;
  nivel_alerta: 'BAJO' | 'MEDIO' | 'ALTO';
  incidentes: Incidente[];
}

export default function VehiculoHistorialScreen() {
  const route = useRoute<RouteProp<RouteParams, 'VehiculoHistorial'>>();
  const { placa } = route.params;

  const [historial, setHistorial] = useState<VehiculoHistorial | null>(null);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const fetchHistorial = async () => {
    try {
      setError(null);
      const response = await api.get(`/intelligence/vehiculo/${placa}`);
      if (response.data.success) {
        setHistorial(response.data.data);
      }
    } catch (err: any) {
      console.error('Error fetching historial:', err);
      setError('Error al cargar el historial del vehículo');
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  };

  useEffect(() => {
    fetchHistorial();
  }, [placa]);

  const onRefresh = () => {
    setRefreshing(true);
    fetchHistorial();
  };

  const getNivelAlertaColor = (nivel: string) => {
    switch (nivel) {
      case 'ALTO': return '#d32f2f';
      case 'MEDIO': return '#ff9800';
      case 'BAJO': return '#4caf50';
      default: return '#757575';
    }
  };

  const formatDate = (dateString: string) => {
    if (!dateString) return 'N/A';
    const date = new Date(dateString);
    return date.toLocaleDateString('es-GT', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  };

  if (loading) {
    return (
      <View style={styles.centerContainer}>
        <ActivityIndicator size="large" color="#1976d2" />
        <Text style={styles.loadingText}>Cargando historial...</Text>
      </View>
    );
  }

  if (error) {
    return (
      <View style={styles.centerContainer}>
        <Text style={styles.errorText}>{error}</Text>
      </View>
    );
  }

  if (!historial) {
    return (
      <View style={styles.centerContainer}>
        <Text style={styles.emptyText}>No se encontró historial para esta placa</Text>
      </View>
    );
  }

  return (
    <ScrollView
      style={styles.container}
      refreshControl={
        <RefreshControl refreshing={refreshing} onRefresh={onRefresh} />
      }
    >
      {/* Encabezado con información del vehículo */}
      <Surface style={styles.headerCard}>
        <View style={styles.headerContent}>
          <View style={styles.headerInfo}>
            <Title style={styles.placa}>{historial.placa}</Title>
            {historial.es_extranjero && (
              <Chip mode="outlined" style={styles.chipExtranjero}>
                Extranjero
              </Chip>
            )}
          </View>

          <Chip
            mode="flat"
            style={[
              styles.chipAlerta,
              { backgroundColor: getNivelAlertaColor(historial.nivel_alerta) }
            ]}
            textStyle={styles.chipAlertaText}
          >
            {historial.nivel_alerta}
          </Chip>
        </View>

        <Divider style={styles.divider} />

        <View style={styles.vehicleDetails}>
          <View style={styles.detailRow}>
            <Text style={styles.detailLabel}>Tipo:</Text>
            <Text style={styles.detailValue}>{historial.tipo_vehiculo || 'N/A'}</Text>
          </View>
          <View style={styles.detailRow}>
            <Text style={styles.detailLabel}>Marca:</Text>
            <Text style={styles.detailValue}>{historial.marca || 'N/A'}</Text>
          </View>
          <View style={styles.detailRow}>
            <Text style={styles.detailLabel}>Color:</Text>
            <Text style={styles.detailValue}>{historial.color || 'N/A'}</Text>
          </View>
        </View>
      </Surface>

      {/* Estadísticas */}
      <Card style={styles.statsCard}>
        <Card.Content>
          <Title style={styles.sectionTitle}>Estadísticas</Title>
          <View style={styles.statsGrid}>
            <View style={styles.statItem}>
              <Text style={styles.statValue}>{historial.total_incidentes}</Text>
              <Text style={styles.statLabel}>Total Incidentes</Text>
            </View>
            <View style={styles.statItem}>
              <Text style={styles.statValue}>
                {historial.dias_desde_ultimo_incidente || 'N/A'}
              </Text>
              <Text style={styles.statLabel}>Días desde último</Text>
            </View>
            <View style={styles.statItem}>
              <Text style={styles.statValue}>
                {historial.dias_desde_primer_incidente || 'N/A'}
              </Text>
              <Text style={styles.statLabel}>Días desde primero</Text>
            </View>
          </View>

          {historial.primer_incidente && (
            <>
              <Divider style={styles.divider} />
              <View style={styles.dateRow}>
                <Text style={styles.dateLabel}>Primer incidente:</Text>
                <Text style={styles.dateValue}>{formatDate(historial.primer_incidente)}</Text>
              </View>
            </>
          )}

          {historial.ultimo_incidente && (
            <View style={styles.dateRow}>
              <Text style={styles.dateLabel}>Último incidente:</Text>
              <Text style={styles.dateValue}>{formatDate(historial.ultimo_incidente)}</Text>
            </View>
          )}
        </Card.Content>
      </Card>

      {/* Lista de Incidentes */}
      <Card style={styles.incidentesCard}>
        <Card.Content>
          <View style={styles.incidentesHeader}>
            <Title style={styles.sectionTitle}>Historial de Incidentes</Title>
            <Badge size={24}>{historial.incidentes?.length || 0}</Badge>
          </View>

          {historial.incidentes && historial.incidentes.length > 0 ? (
            historial.incidentes.map((incidente, index) => (
              <List.Item
                key={`incidente-${incidente.incidente_id}-${index}`}
                title={incidente.tipo_hecho || 'Sin tipo'}
                description={`${formatDate(incidente.fecha)}\n${incidente.ruta_codigo} - Km ${incidente.km}\n${incidente.municipio || 'N/A'}`}
                left={(props) => (
                  <List.Icon
                    {...props}
                    icon="car-emergency"
                    color={
                      incidente.cantidad_fallecidos > 0 ? '#d32f2f' :
                      incidente.cantidad_heridos > 0 ? '#ff9800' : '#1976d2'
                    }
                  />
                )}
                right={(props) => (
                  <View style={styles.incidenteRight}>
                    {incidente.cantidad_fallecidos > 0 && (
                      <Chip
                        icon="skull"
                        style={styles.chipFallecidos}
                        textStyle={styles.chipText}
                      >
                        {incidente.cantidad_fallecidos}
                      </Chip>
                    )}
                    {incidente.cantidad_heridos > 0 && (
                      <Chip
                        icon="ambulance"
                        style={styles.chipHeridos}
                        textStyle={styles.chipText}
                      >
                        {incidente.cantidad_heridos}
                      </Chip>
                    )}
                  </View>
                )}
                style={styles.incidenteItem}
              />
            ))
          ) : (
            <View style={styles.emptyIncidentes}>
              <Text style={styles.emptyText}>No hay incidentes registrados</Text>
            </View>
          )}
        </Card.Content>
      </Card>

      <View style={styles.bottomPadding} />
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  centerContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
  },
  loadingText: {
    marginTop: 10,
    fontSize: 16,
    color: '#666',
  },
  errorText: {
    fontSize: 16,
    color: '#d32f2f',
    textAlign: 'center',
  },
  emptyText: {
    fontSize: 16,
    color: '#666',
    textAlign: 'center',
  },
  headerCard: {
    margin: 16,
    padding: 16,
    elevation: 4,
    borderRadius: 8,
  },
  headerContent: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  headerInfo: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  placa: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#1976d2',
  },
  chipExtranjero: {
    height: 28,
  },
  chipAlerta: {
    height: 32,
  },
  chipAlertaText: {
    color: '#fff',
    fontWeight: 'bold',
    fontSize: 12,
  },
  divider: {
    marginVertical: 12,
  },
  vehicleDetails: {
    gap: 8,
  },
  detailRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  detailLabel: {
    fontSize: 14,
    color: '#666',
    fontWeight: '500',
  },
  detailValue: {
    fontSize: 14,
    color: '#333',
    fontWeight: '600',
  },
  statsCard: {
    marginHorizontal: 16,
    marginBottom: 16,
    elevation: 2,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: 12,
  },
  statsGrid: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    marginBottom: 12,
  },
  statItem: {
    alignItems: 'center',
  },
  statValue: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#1976d2',
  },
  statLabel: {
    fontSize: 12,
    color: '#666',
    marginTop: 4,
    textAlign: 'center',
  },
  dateRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginVertical: 4,
  },
  dateLabel: {
    fontSize: 13,
    color: '#666',
  },
  dateValue: {
    fontSize: 13,
    color: '#333',
    fontWeight: '600',
  },
  incidentesCard: {
    marginHorizontal: 16,
    marginBottom: 16,
    elevation: 2,
  },
  incidentesHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 8,
  },
  incidenteItem: {
    paddingVertical: 8,
    borderBottomWidth: 1,
    borderBottomColor: '#e0e0e0',
  },
  incidenteRight: {
    flexDirection: 'row',
    gap: 4,
    alignItems: 'center',
  },
  chipFallecidos: {
    backgroundColor: '#d32f2f',
    height: 24,
  },
  chipHeridos: {
    backgroundColor: '#ff9800',
    height: 24,
  },
  chipText: {
    color: '#fff',
    fontSize: 11,
  },
  emptyIncidentes: {
    padding: 20,
    alignItems: 'center',
  },
  bottomPadding: {
    height: 20,
  },
});
