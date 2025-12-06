import React, { useEffect, useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  FlatList,
  TouchableOpacity,
  RefreshControl,
  ActivityIndicator,
} from 'react-native';
import { useSituacionesStore, SituacionCompleta } from '../../store/situacionesStore';
import { COLORS } from '../../constants/colors';
import { SITUACIONES_CONFIG, TipoSituacion } from '../../constants/situacionTypes';
import { useNavigation } from '@react-navigation/native';

export default function BitacoraScreen() {
  const navigation = useNavigation();
  const { situacionesHoy, fetchMisSituacionesHoy, isLoading } = useSituacionesStore();
  const [refreshing, setRefreshing] = useState(false);
  const [filtroTipo, setFiltroTipo] = useState<TipoSituacion | null>(null);

  useEffect(() => {
    loadSituaciones();
  }, []);

  const loadSituaciones = async () => {
    try {
      await fetchMisSituacionesHoy();
    } catch (error) {
      console.error('Error al cargar situaciones:', error);
    }
  };

  const handleRefresh = async () => {
    setRefreshing(true);
    await loadSituaciones();
    setRefreshing(false);
  };

  const getTipoColor = (tipo: TipoSituacion) => {
    return SITUACIONES_CONFIG[tipo]?.color || COLORS.primary;
  };

  const formatFecha = (fecha: string) => {
    const date = new Date(fecha);
    return date.toLocaleTimeString('es-GT', {
      hour: '2-digit',
      minute: '2-digit',
    });
  };

  const formatDuracion = (inicio: string, fin?: string) => {
    const start = new Date(inicio);
    const end = fin ? new Date(fin) : new Date();
    const diff = end.getTime() - start.getTime();
    const hours = Math.floor(diff / (1000 * 60 * 60));
    const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));

    if (hours > 0) {
      return `${hours}h ${minutes}m`;
    }
    return `${minutes}m`;
  };

  const situacionesFiltradas = filtroTipo
    ? situacionesHoy.filter((s) => s.tipo_situacion === filtroTipo)
    : situacionesHoy;

  const renderSituacionCard = ({ item }: { item: SituacionCompleta }) => {
    const config = SITUACIONES_CONFIG[item.tipo_situacion];
    const isActiva = item.estado === 'ACTIVA';

    return (
      <TouchableOpacity
        style={[
          styles.card,
          isActiva && { borderLeftWidth: 4, borderLeftColor: COLORS.success },
        ]}
        onPress={() => {
          navigation.navigate('DetalleSituacion' as never, { situacionId: item.id } as never);
        }}
      >
        <View style={styles.cardHeader}>
          <View style={styles.cardHeaderLeft}>
            <View
              style={[styles.tipoBadge, { backgroundColor: getTipoColor(item.tipo_situacion) }]}
            >
              <Text style={styles.tipoBadgeText}>{config?.label || item.tipo_situacion}</Text>
            </View>
            {isActiva && (
              <View style={[styles.estadoBadge, { backgroundColor: COLORS.success }]}>
                <Text style={styles.estadoBadgeText}>ACTIVA</Text>
              </View>
            )}
          </View>
          {item.numero_situacion && (
            <Text style={styles.numeroSituacion}>{item.numero_situacion}</Text>
          )}
        </View>

        <View style={styles.cardContent}>
          <View style={styles.infoRow}>
            <Text style={styles.infoLabel}>Inicio:</Text>
            <Text style={styles.infoValue}>{formatFecha(item.created_at)}</Text>
          </View>

          {!isActiva && (
            <View style={styles.infoRow}>
              <Text style={styles.infoLabel}>Duración:</Text>
              <Text style={styles.infoValue}>
                {formatDuracion(item.created_at, item.updated_at)}
              </Text>
            </View>
          )}

          {item.ruta_codigo && (
            <View style={styles.infoRow}>
              <Text style={styles.infoLabel}>Ubicación:</Text>
              <Text style={styles.infoValue}>
                {item.ruta_codigo} {item.km ? `Km ${item.km}` : ''}
              </Text>
            </View>
          )}

          {item.descripcion && (
            <View style={styles.descriptionContainer}>
              <Text style={styles.descripcionText} numberOfLines={2}>
                {item.descripcion}
              </Text>
            </View>
          )}
        </View>
      </TouchableOpacity>
    );
  };

  const renderFiltros = () => {
    // Obtener tipos únicos de las situaciones del día
    const tiposDisponibles = Array.from(
      new Set(situacionesHoy.map((s) => s.tipo_situacion))
    ) as TipoSituacion[];

    return (
      <View style={styles.filtrosContainer}>
        <TouchableOpacity
          style={[
            styles.filtroButton,
            !filtroTipo && styles.filtroButtonSelected,
          ]}
          onPress={() => setFiltroTipo(null)}
        >
          <Text
            style={[
              styles.filtroButtonText,
              !filtroTipo && styles.filtroButtonTextSelected,
            ]}
          >
            Todas ({situacionesHoy.length})
          </Text>
        </TouchableOpacity>

        {tiposDisponibles.map((tipo) => {
          const config = SITUACIONES_CONFIG[tipo];
          const count = situacionesHoy.filter((s) => s.tipo_situacion === tipo).length;

          return (
            <TouchableOpacity
              key={tipo}
              style={[
                styles.filtroButton,
                filtroTipo === tipo && {
                  backgroundColor: config.color,
                  borderColor: config.color,
                },
              ]}
              onPress={() => setFiltroTipo(tipo)}
            >
              <Text
                style={[
                  styles.filtroButtonText,
                  filtroTipo === tipo && styles.filtroButtonTextSelected,
                ]}
              >
                {config.label} ({count})
              </Text>
            </TouchableOpacity>
          );
        })}
      </View>
    );
  };

  const renderEmptyState = () => (
    <View style={styles.emptyState}>
      <Text style={styles.emptyStateText}>
        {filtroTipo
          ? 'No hay situaciones de este tipo hoy'
          : 'No hay situaciones registradas hoy'}
      </Text>
      <Text style={styles.emptyStateSubtext}>
        Las situaciones que crees aparecerán aquí
      </Text>
    </View>
  );

  if (isLoading && situacionesHoy.length === 0) {
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicator size="large" color={COLORS.primary} />
        <Text style={styles.loadingText}>Cargando bitácora...</Text>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      {/* Header con resumen */}
      <View style={styles.header}>
        <Text style={styles.headerTitle}>Bitácora de Hoy</Text>
        <Text style={styles.headerSubtitle}>
          {situacionesHoy.length} situacion{situacionesHoy.length !== 1 ? 'es' : ''}
        </Text>
      </View>

      {/* Filtros */}
      {situacionesHoy.length > 0 && renderFiltros()}

      {/* Lista de situaciones */}
      <FlatList
        data={situacionesFiltradas}
        keyExtractor={(item) => item.id.toString()}
        renderItem={renderSituacionCard}
        contentContainerStyle={styles.listContent}
        refreshControl={
          <RefreshControl refreshing={refreshing} onRefresh={handleRefresh} />
        }
        ListEmptyComponent={renderEmptyState}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.background,
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: COLORS.background,
  },
  loadingText: {
    marginTop: 12,
    fontSize: 16,
    color: COLORS.text.secondary,
  },
  header: {
    backgroundColor: COLORS.white,
    padding: 16,
    borderBottomWidth: 1,
    borderBottomColor: COLORS.border,
  },
  headerTitle: {
    fontSize: 20,
    fontWeight: '600',
    color: COLORS.text.primary,
  },
  headerSubtitle: {
    fontSize: 14,
    color: COLORS.text.secondary,
    marginTop: 4,
  },
  filtrosContainer: {
    backgroundColor: COLORS.white,
    padding: 12,
    borderBottomWidth: 1,
    borderBottomColor: COLORS.border,
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
  },
  filtroButton: {
    paddingVertical: 6,
    paddingHorizontal: 12,
    borderRadius: 16,
    backgroundColor: COLORS.background,
    borderWidth: 1,
    borderColor: COLORS.border,
  },
  filtroButtonSelected: {
    backgroundColor: COLORS.primary,
    borderColor: COLORS.primary,
  },
  filtroButtonText: {
    fontSize: 13,
    color: COLORS.text.primary,
    fontWeight: '500',
  },
  filtroButtonTextSelected: {
    color: COLORS.white,
    fontWeight: '600',
  },
  listContent: {
    padding: 16,
    paddingBottom: 80,
  },
  card: {
    backgroundColor: COLORS.white,
    borderRadius: 12,
    marginBottom: 12,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  cardHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: 12,
    borderBottomWidth: 1,
    borderBottomColor: COLORS.border,
  },
  cardHeaderLeft: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
    flex: 1,
  },
  tipoBadge: {
    paddingVertical: 4,
    paddingHorizontal: 10,
    borderRadius: 12,
  },
  tipoBadgeText: {
    color: COLORS.white,
    fontSize: 12,
    fontWeight: '600',
  },
  estadoBadge: {
    paddingVertical: 3,
    paddingHorizontal: 8,
    borderRadius: 10,
  },
  estadoBadgeText: {
    color: COLORS.white,
    fontSize: 10,
    fontWeight: '700',
  },
  numeroSituacion: {
    fontSize: 12,
    fontWeight: '600',
    color: COLORS.text.secondary,
  },
  cardContent: {
    padding: 12,
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
  descriptionContainer: {
    marginTop: 8,
    paddingTop: 8,
    borderTopWidth: 1,
    borderTopColor: COLORS.border,
  },
  descripcionText: {
    fontSize: 14,
    color: COLORS.text.primary,
    lineHeight: 20,
  },
  emptyState: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingVertical: 60,
  },
  emptyStateText: {
    fontSize: 18,
    fontWeight: '500',
    color: COLORS.text.secondary,
    textAlign: 'center',
    marginBottom: 8,
  },
  emptyStateSubtext: {
    fontSize: 14,
    color: COLORS.text.disabled,
    textAlign: 'center',
  },
});
