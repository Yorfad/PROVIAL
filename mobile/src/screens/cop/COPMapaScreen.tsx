import React, { useEffect, useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  ActivityIndicator,
  Modal,
  ScrollView,
} from 'react-native';
import MapView, { Marker, PROVIDER_GOOGLE } from 'react-native-maps';
import { useMapStore } from '../../store/mapStore';
import { COLORS } from '../../constants/colors';
import { SITUACIONES_CONFIG } from '../../constants/situacionTypes';

// Coordenadas del centro de Guatemala (aproximado)
const GUATEMALA_CENTER = {
  latitude: 14.6349,
  longitude: -90.5069,
  latitudeDelta: 2.5,
  longitudeDelta: 2.5,
};

export default function COPMapaScreen() {
  const {
    unidades,
    selectedUnidad,
    fetchUnidades,
    selectUnidad,
    isLoading,
  } = useMapStore();

  const [region, setRegion] = useState(GUATEMALA_CENTER);
  const [showDetailModal, setShowDetailModal] = useState(false);

  useEffect(() => {
    loadData();
    // Auto-refresh cada 30 segundos
    const interval = setInterval(loadData, 30000);
    return () => clearInterval(interval);
  }, []);

  const loadData = async () => {
    try {
      await fetchUnidades();
    } catch (error) {
      console.error('Error al cargar situaciones:', error);
    }
  };

  const handleMarkerPress = (situacion: any) => {
    selectUnidad(situacion);
    setShowDetailModal(true);

    // Centrar mapa en el marker
    if (situacion.latitud && situacion.longitud) {
      setRegion({
        latitude: situacion.latitud,
        longitude: situacion.longitud,
        latitudeDelta: 0.1,
        longitudeDelta: 0.1,
      });
    }
  };

  const getMarkerColor = (tipoSituacion: string, estado: string) => {
    if (estado !== 'ACTIVA') {
      return COLORS.gray[400];
    }

    const config = SITUACIONES_CONFIG[tipoSituacion as keyof typeof SITUACIONES_CONFIG];
    return config?.color || COLORS.primary;
  };

  const formatFecha = (fecha: string) => {
    const date = new Date(fecha);
    const now = new Date();
    const diff = now.getTime() - date.getTime();
    const minutes = Math.floor(diff / 60000);

    if (minutes < 1) return 'Hace un momento';
    if (minutes < 60) return `Hace ${minutes} min`;

    const hours = Math.floor(minutes / 60);
    if (hours < 24) return `Hace ${hours}h`;

    return date.toLocaleDateString('es-GT', {
      day: '2-digit',
      month: '2-digit',
      hour: '2-digit',
      minute: '2-digit',
    });
  };

  const renderDetailModal = () => {
    if (!selectedUnidad) return null;

    const config = SITUACIONES_CONFIG[
      selectedUnidad.tipo_situacion as keyof typeof SITUACIONES_CONFIG
    ];

    return (
      <Modal
        visible={showDetailModal}
        transparent={true}
        animationType="slide"
        onRequestClose={() => setShowDetailModal(false)}
      >
        <View style={styles.modalOverlay}>
          <View style={styles.modalContent}>
            <View style={styles.modalHeader}>
              <Text style={styles.modalTitle}>{selectedUnidad.unidad_codigo}</Text>
              <TouchableOpacity
                style={styles.closeButton}
                onPress={() => setShowDetailModal(false)}
              >
                <Text style={styles.closeButtonText}>✕</Text>
              </TouchableOpacity>
            </View>

            <ScrollView style={styles.modalBody}>
              {/* Tipo de situación */}
              <View
                style={[
                  styles.tipoBadgeLarge,
                  { backgroundColor: config?.color || COLORS.primary },
                ]}
              >
                <Text style={styles.tipoBadgeLargeText}>
                  {config?.label || selectedUnidad.tipo_situacion}
                </Text>
              </View>

              {/* Estado */}
              <View style={styles.modalSection}>
                <Text style={styles.modalSectionTitle}>Estado</Text>
                <View
                  style={[
                    styles.estadoBadge,
                    {
                      backgroundColor:
                        selectedUnidad.estado === 'ACTIVA'
                          ? COLORS.success
                          : COLORS.gray[400],
                    },
                  ]}
                >
                  <Text style={styles.estadoBadgeText}>{selectedUnidad.estado}</Text>
                </View>
              </View>

              {/* Información de la unidad */}
              <View style={styles.modalSection}>
                <Text style={styles.modalSectionTitle}>Información</Text>
                <View style={styles.infoRow}>
                  <Text style={styles.infoLabel}>Tipo Unidad:</Text>
                  <Text style={styles.infoValue}>{selectedUnidad.tipo_unidad}</Text>
                </View>
                {selectedUnidad.numero_situacion && (
                  <View style={styles.infoRow}>
                    <Text style={styles.infoLabel}>No. Situación:</Text>
                    <Text style={styles.infoValue}>{selectedUnidad.numero_situacion}</Text>
                  </View>
                )}
              </View>

              {/* Ubicación */}
              <View style={styles.modalSection}>
                <Text style={styles.modalSectionTitle}>Ubicación</Text>
                {selectedUnidad.ruta_codigo && (
                  <View style={styles.infoRow}>
                    <Text style={styles.infoLabel}>Ruta:</Text>
                    <Text style={styles.infoValue}>{selectedUnidad.ruta_codigo}</Text>
                  </View>
                )}
                {selectedUnidad.km && (
                  <View style={styles.infoRow}>
                    <Text style={styles.infoLabel}>Kilómetro:</Text>
                    <Text style={styles.infoValue}>{selectedUnidad.km}</Text>
                  </View>
                )}
                {selectedUnidad.sentido && (
                  <View style={styles.infoRow}>
                    <Text style={styles.infoLabel}>Sentido:</Text>
                    <Text style={styles.infoValue}>{selectedUnidad.sentido}</Text>
                  </View>
                )}
                {selectedUnidad.latitud && selectedUnidad.longitud && (
                  <View style={styles.infoRow}>
                    <Text style={styles.infoLabel}>Coordenadas:</Text>
                    <Text style={styles.infoValue}>
                      {selectedUnidad.latitud.toFixed(5)}, {selectedUnidad.longitud.toFixed(5)}
                    </Text>
                  </View>
                )}
              </View>

              {/* Descripción */}
              {selectedUnidad.descripcion && (
                <View style={styles.modalSection}>
                  <Text style={styles.modalSectionTitle}>Descripción</Text>
                  <Text style={styles.descripcionText}>{selectedUnidad.descripcion}</Text>
                </View>
              )}

              {/* Timestamp */}
              <View style={styles.modalSection}>
                <Text style={styles.modalSectionTitle}>Última Actualización</Text>
                <Text style={styles.timestampText}>
                  {formatFecha(selectedUnidad.created_at)}
                </Text>
              </View>
            </ScrollView>
          </View>
        </View>
      </Modal>
    );
  };

  return (
    <View style={styles.container}>
      {/* Mapa */}
      <MapView
        provider={PROVIDER_GOOGLE}
        style={styles.map}
        initialRegion={region}
        region={region}
        onRegionChangeComplete={setRegion}
      >
        {unidades
          .filter((s) => s.latitud && s.longitud)
          .map((situacion) => (
            <Marker
              key={situacion.unidad_id}
              coordinate={{
                latitude: situacion.latitud!,
                longitude: situacion.longitud!,
              }}
              pinColor={getMarkerColor(situacion.tipo_situacion, situacion.estado)}
              title={situacion.unidad_codigo}
              description={`${SITUACIONES_CONFIG[situacion.tipo_situacion as keyof typeof SITUACIONES_CONFIG]?.label || situacion.tipo_situacion} - ${situacion.estado}`}
              onPress={() => handleMarkerPress(situacion)}
            />
          ))}
      </MapView>

      {/* Header flotante con resumen */}
      <View style={styles.headerCard}>
        <Text style={styles.headerTitle}>Unidades Activas</Text>
        <Text style={styles.headerCount}>
          {unidades.filter((s) => s.estado === 'ACTIVA').length} /{' '}
          {unidades.length}
        </Text>
      </View>

      {/* Botón de refresh */}
      <TouchableOpacity
        style={styles.refreshButton}
        onPress={loadData}
        disabled={isLoading}
      >
        {isLoading ? (
          <ActivityIndicator color={COLORS.white} size="small" />
        ) : (
          <Text style={styles.refreshButtonText}>↻</Text>
        )}
      </TouchableOpacity>

      {/* Loading overlay */}
      {isLoading && unidades.length === 0 && (
        <View style={styles.loadingOverlay}>
          <ActivityIndicator size="large" color={COLORS.primary} />
          <Text style={styles.loadingText}>Cargando mapa...</Text>
        </View>
      )}

      {/* Modal de detalle */}
      {renderDetailModal()}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  map: {
    flex: 1,
  },
  headerCard: {
    position: 'absolute',
    top: 16,
    left: 16,
    right: 16,
    backgroundColor: COLORS.white,
    borderRadius: 12,
    padding: 16,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.25,
    shadowRadius: 3.84,
    elevation: 5,
  },
  headerTitle: {
    fontSize: 18,
    fontWeight: '600',
    color: COLORS.text.primary,
  },
  headerCount: {
    fontSize: 24,
    fontWeight: 'bold',
    color: COLORS.primary,
  },
  refreshButton: {
    position: 'absolute',
    bottom: 24,
    right: 16,
    backgroundColor: COLORS.primary,
    width: 56,
    height: 56,
    borderRadius: 28,
    justifyContent: 'center',
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.25,
    shadowRadius: 3.84,
    elevation: 5,
  },
  refreshButtonText: {
    fontSize: 32,
    color: COLORS.white,
    fontWeight: 'bold',
  },
  loadingOverlay: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    backgroundColor: 'rgba(255, 255, 255, 0.9)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  loadingText: {
    marginTop: 12,
    fontSize: 16,
    color: COLORS.text.secondary,
  },
  modalOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    justifyContent: 'flex-end',
  },
  modalContent: {
    backgroundColor: COLORS.white,
    borderTopLeftRadius: 20,
    borderTopRightRadius: 20,
    maxHeight: '80%',
  },
  modalHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: 20,
    borderBottomWidth: 1,
    borderBottomColor: COLORS.border,
  },
  modalTitle: {
    fontSize: 20,
    fontWeight: '600',
    color: COLORS.text.primary,
  },
  closeButton: {
    width: 32,
    height: 32,
    borderRadius: 16,
    backgroundColor: COLORS.gray[200],
    justifyContent: 'center',
    alignItems: 'center',
  },
  closeButtonText: {
    fontSize: 20,
    color: COLORS.text.primary,
    fontWeight: '600',
  },
  modalBody: {
    padding: 20,
  },
  tipoBadgeLarge: {
    paddingVertical: 12,
    paddingHorizontal: 20,
    borderRadius: 12,
    alignSelf: 'flex-start',
    marginBottom: 20,
  },
  tipoBadgeLargeText: {
    color: COLORS.white,
    fontSize: 16,
    fontWeight: '600',
  },
  modalSection: {
    marginBottom: 20,
  },
  modalSectionTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: COLORS.text.primary,
    marginBottom: 12,
  },
  estadoBadge: {
    paddingVertical: 6,
    paddingHorizontal: 12,
    borderRadius: 12,
    alignSelf: 'flex-start',
  },
  estadoBadgeText: {
    color: COLORS.white,
    fontSize: 14,
    fontWeight: '600',
  },
  infoRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 8,
  },
  infoLabel: {
    fontSize: 14,
    color: COLORS.text.secondary,
    fontWeight: '500',
  },
  infoValue: {
    fontSize: 14,
    color: COLORS.text.primary,
    fontWeight: '600',
  },
  descripcionText: {
    fontSize: 14,
    color: COLORS.text.primary,
    lineHeight: 20,
  },
  timestampText: {
    fontSize: 14,
    color: COLORS.text.secondary,
    fontStyle: 'italic',
  },
});
