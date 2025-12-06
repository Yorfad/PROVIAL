import React, { useEffect, useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  RefreshControl,
  Alert,
  ActivityIndicator,
} from 'react-native';
import { useAuthStore } from '../../store/authStore';
import { useSituacionesStore } from '../../store/situacionesStore';
import { COLORS } from '../../constants/colors';
import { useNavigation } from '@react-navigation/native';
import { turnosAPI } from '../../services/api';
import RutaSelector from '../../components/RutaSelector';

export default function BrigadaHomeScreen() {
  const navigation = useNavigation();
  const { usuario, asignacion, salidaActiva, ingresoActivo, verificarAcceso, refreshEstadoBrigada } = useAuthStore();
  const { situacionActiva, fetchMisSituacionesHoy, cerrarSituacion, isLoading } = useSituacionesStore();

  const [refreshing, setRefreshing] = useState(false);
  const [accesoInfo, setAccesoInfo] = useState<{ tiene_acceso: boolean; motivo_bloqueo: string | null } | null>(null);
  const [mostrarCambioRuta, setMostrarCambioRuta] = useState(false);
  const [nuevaRutaId, setNuevaRutaId] = useState<number | null>(null);
  const [cambiandoRuta, setCambiandoRuta] = useState(false);
  const [asignacionDia, setAsignacionDia] = useState<any>(null);
  const [loadingAsignacionDia, setLoadingAsignacionDia] = useState(false);

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    try {
      // Verificar acceso según grupo
      const acceso = await verificarAcceso();
      setAccesoInfo(acceso);

      // Refresh estado completo de brigada (asignación, salida, ingreso, sede)
      await refreshEstadoBrigada();

      // Fetch situaciones del día
      await fetchMisSituacionesHoy();

      // Obtener asignación del día (turno operacional)
      await loadAsignacionDia();
    } catch (error) {
      console.error('Error al cargar datos:', error);
    }
  };

  const loadAsignacionDia = async () => {
    try {
      setLoadingAsignacionDia(true);
      const asignacion = await turnosAPI.getMiAsignacionHoy();
      setAsignacionDia(asignacion);
    } catch (error: any) {
      // Si no hay asignación, no es un error crítico
      console.log('[ASIGNACION DIA] No hay asignación para hoy');
      setAsignacionDia(null);
    } finally {
      setLoadingAsignacionDia(false);
    }
  };

  const handleRefresh = async () => {
    setRefreshing(true);
    await loadData();
    setRefreshing(false);
  };

  const handleCerrarSituacion = () => {
    if (!situacionActiva) return;

    Alert.alert(
      'Cerrar Situación',
      '¿Desea cerrar la situación actual?',
      [
        {
          text: 'Cancelar',
          style: 'cancel',
        },
        {
          text: 'Cerrar',
          onPress: async () => {
            try {
              await cerrarSituacion(situacionActiva.id);
              Alert.alert('Éxito', 'Situación cerrada correctamente');
            } catch (error: any) {
              Alert.alert('Error', error.message || 'No se pudo cerrar la situación');
            }
          },
        },
      ]
    );
  };

  const handleCambiarRuta = async () => {
    if (!nuevaRutaId) {
      Alert.alert('Error', 'Debes seleccionar una ruta');
      return;
    }

    try {
      setCambiandoRuta(true);
      console.log('[CAMBIAR RUTA] Cambiando a ruta ID:', nuevaRutaId);

      const response = await turnosAPI.cambiarRuta(nuevaRutaId);
      console.log('[CAMBIAR RUTA] Respuesta:', response);

      console.log('[CAMBIAR RUTA] Refrescando estado...');
      await refreshEstadoBrigada();

      setMostrarCambioRuta(false);
      setNuevaRutaId(null);
      Alert.alert('Éxito', 'Ruta cambiada correctamente');
    } catch (error: any) {
      console.error('[CAMBIAR RUTA] Error:', error);
      const mensaje = error.response?.data?.error || error.message || 'No se pudo cambiar la ruta';
      Alert.alert('Error al cambiar ruta', mensaje);
    } finally {
      setCambiandoRuta(false);
    }
  };

  const getTipoSituacionColor = (tipo: string) => {
    const tipoLower = tipo.toLowerCase();
    if (tipoLower.includes('incidente')) return COLORS.tipoSituacion.incidente;
    if (tipoLower.includes('patrullaje')) return COLORS.tipoSituacion.patrullaje;
    if (tipoLower.includes('salida')) return COLORS.tipoSituacion.salida;
    if (tipoLower.includes('parada')) return COLORS.tipoSituacion.parada;
    if (tipoLower.includes('comida')) return COLORS.tipoSituacion.comida;
    if (tipoLower.includes('asistencia')) return COLORS.tipoSituacion.asistencia;
    return COLORS.primary;
  };

  const formatFecha = (fecha: string) => {
    const date = new Date(fecha);
    return date.toLocaleTimeString('es-GT', {
      hour: '2-digit',
      minute: '2-digit'
    });
  };

  return (
    <ScrollView
      style={styles.container}
      refreshControl={
        <RefreshControl refreshing={refreshing} onRefresh={handleRefresh} />
      }
    >
      {/* Header con información del usuario */}
      <View style={styles.header}>
        <View style={styles.headerTop}>
          <View>
            <Text style={styles.welcomeText}>Bienvenido,</Text>
            <Text style={styles.userName}>{usuario?.nombre}</Text>
          </View>
          <TouchableOpacity
            style={styles.logoutButton}
            onPress={() => {
              Alert.alert(
                'Cerrar Sesión',
                '¿Estás seguro que deseas cerrar sesión?',
                [
                  { text: 'Cancelar', style: 'cancel' },
                  {
                    text: 'Salir',
                    style: 'destructive',
                    onPress: async () => {
                      await useAuthStore.getState().logout();
                    },
                  },
                ]
              );
            }}
          >
            <Text style={styles.logoutButtonText}>Salir</Text>
          </TouchableOpacity>
        </View>

        {/* Indicador de acceso */}
        {accesoInfo && (
          <View style={[
            styles.accesoIndicator,
            { backgroundColor: accesoInfo.tiene_acceso ? COLORS.success : COLORS.warning }
          ]}>
            <Text style={styles.accesoText}>
              {accesoInfo.tiene_acceso
                ? '✓ Acceso permitido hoy'
                : `⚠ ${accesoInfo.motivo_bloqueo}`}
            </Text>
          </View>
        )}
      </View>

      {/* Card de Asignación Permanente */}
      {asignacion ? (
        <View style={styles.card}>
          <View style={styles.cardHeader}>
            <Text style={styles.cardTitle}>Tu Unidad Asignada</Text>
          </View>
          <View style={styles.cardContent}>
            <View style={styles.infoRow}>
              <Text style={styles.infoLabel}>Unidad:</Text>
              <Text style={styles.infoValue}>{asignacion.unidad_codigo}</Text>
            </View>
            <View style={styles.infoRow}>
              <Text style={styles.infoLabel}>Tipo:</Text>
              <Text style={styles.infoValue}>{asignacion.tipo_unidad}</Text>
            </View>
            <View style={styles.infoRow}>
              <Text style={styles.infoLabel}>Tu Rol:</Text>
              <Text style={styles.infoValue}>{asignacion.rol_tripulacion}</Text>
            </View>
          </View>
        </View>
      ) : (
        <View style={[styles.card, styles.warningCard]}>
          <Text style={styles.warningText}>
            No tienes unidad asignada
          </Text>
        </View>
      )}

      {/* Card de Asignación del Día (Turno Operacional) */}
      {loadingAsignacionDia ? (
        <View style={styles.card}>
          <ActivityIndicator size="small" color={COLORS.primary} />
          <Text style={{ textAlign: 'center', color: COLORS.text.secondary, marginTop: 8 }}>
            Cargando asignación del día...
          </Text>
        </View>
      ) : asignacionDia ? (
        <View style={[styles.card, { borderLeftWidth: 4, borderLeftColor: COLORS.info }]}>
          <View style={styles.cardHeader}>
            <Text style={styles.cardTitle}>📋 Turno de Hoy</Text>
            <View style={[styles.tipoBadge, { backgroundColor: COLORS.info }]}>
              <Text style={styles.tipoBadgeText}>OPERACIONAL</Text>
            </View>
          </View>
          <View style={styles.cardContent}>
            <View style={styles.infoRow}>
              <Text style={styles.infoLabel}>Unidad:</Text>
              <Text style={styles.infoValue}>{asignacionDia.unidad_codigo}</Text>
            </View>
            <View style={styles.infoRow}>
              <Text style={styles.infoLabel}>Rol:</Text>
              <Text style={styles.infoValue}>{asignacionDia.mi_rol}</Text>
            </View>
            {asignacionDia.ruta_codigo && (
              <View style={styles.infoRow}>
                <Text style={styles.infoLabel}>Ruta:</Text>
                <Text style={styles.infoValue}>
                  {asignacionDia.ruta_codigo} {asignacionDia.sentido ? `(${asignacionDia.sentido})` : ''}
                </Text>
              </View>
            )}
            {asignacionDia.hora_salida && (
              <View style={styles.infoRow}>
                <Text style={styles.infoLabel}>Hora Salida:</Text>
                <Text style={styles.infoValue}>{asignacionDia.hora_salida}</Text>
              </View>
            )}
            {asignacionDia.companeros && asignacionDia.companeros.length > 0 && (
              <View style={styles.descriptionRow}>
                <Text style={styles.infoLabel}>Compañeros:</Text>
                <Text style={styles.descripcionText}>
                  {asignacionDia.companeros.map((c: any) => `${c.nombre} (${c.rol})`).join(', ')}
                </Text>
              </View>
            )}
          </View>
          {/* Botón de registro de combustible */}
          <TouchableOpacity
            style={[styles.cerrarButton, { backgroundColor: COLORS.warning, marginTop: 8 }]}
            onPress={() => navigation.navigate('RegistroCombustible' as never)}
          >
            <Text style={styles.cerrarButtonText}>⛽ Registrar Combustible</Text>
          </TouchableOpacity>
        </View>
      ) : null}

      {/* Card de Salida Activa */}
      {salidaActiva ? (
        <TouchableOpacity
          style={[styles.card, styles.situacionActivaCard]}
          onPress={() => navigation.navigate('Bitacora' as never)}
        >
          <View style={styles.cardHeader}>
            <Text style={styles.cardTitle}>Jornada Activa 👆</Text>
            <View style={[styles.tipoBadge, { backgroundColor: COLORS.success }]}>
              <Text style={styles.tipoBadgeText}>{salidaActiva.estado}</Text>
            </View>
          </View>
          <View style={styles.cardContent}>
            <View style={styles.infoRow}>
              <Text style={styles.infoLabel}>Inicio:</Text>
              <Text style={styles.infoValue}>
                {formatFecha(salidaActiva.fecha_hora_salida)}
              </Text>
            </View>
            <View style={styles.infoRow}>
              <Text style={styles.infoLabel}>Unidad:</Text>
              <Text style={styles.infoValue}>{salidaActiva.unidad_codigo}</Text>
            </View>
            <View style={styles.infoRow}>
              <Text style={styles.infoLabel}>Ruta:</Text>
              <Text style={styles.infoValue}>
                {salidaActiva.ruta_codigo || 'Sin ruta asignada'}
              </Text>
            </View>
            <Text style={{ textAlign: 'center', color: COLORS.primary, marginTop: 8, fontSize: 12 }}>
              Toca para ver detalles en Bitácora
            </Text>
          </View>
        </TouchableOpacity>
      ) : asignacion ? (
        <View style={[styles.card, styles.warningCard]}>
          <Text style={styles.warningText}>
            No has iniciado salida hoy
          </Text>
          <TouchableOpacity
            style={[styles.actionButton, styles.primaryButton, { marginHorizontal: 16, marginTop: 12 }]}
            onPress={() => navigation.navigate('IniciarSalida' as never)}
          >
            <Text style={styles.actionButtonText}>🚗 Iniciar Salida</Text>
          </TouchableOpacity>
        </View>
      ) : null}

      {/* Card de Ingreso Activo */}
      {ingresoActivo && !ingresoActivo.es_ingreso_final && (
        <View style={[styles.card, { borderLeftWidth: 4, borderLeftColor: COLORS.warning }]}>
          <View style={styles.cardHeader}>
            <Text style={styles.cardTitle}>En Sede</Text>
            <View style={[styles.tipoBadge, { backgroundColor: COLORS.warning }]}>
              <Text style={styles.tipoBadgeText}>{ingresoActivo.tipo_ingreso}</Text>
            </View>
          </View>
          <View style={styles.cardContent}>
            <View style={styles.infoRow}>
              <Text style={styles.infoLabel}>Sede:</Text>
              <Text style={styles.infoValue}>{ingresoActivo.sede_nombre}</Text>
            </View>
            <View style={styles.infoRow}>
              <Text style={styles.infoLabel}>Ingreso:</Text>
              <Text style={styles.infoValue}>
                {formatFecha(ingresoActivo.fecha_hora_ingreso)}
              </Text>
            </View>
          </View>

          {ingresoActivo.tipo_ingreso === 'FINALIZAR_JORNADA' ? (
            <View>
              <TouchableOpacity
                style={[styles.cerrarButton, { backgroundColor: COLORS.danger, marginBottom: 12 }]}
                onPress={() => navigation.navigate('FinalizarDia' as never)}
              >
                <Text style={styles.cerrarButtonText}>🏁 Finalizar Jornada</Text>
              </TouchableOpacity>
              <TouchableOpacity
                style={[styles.cerrarButton, { backgroundColor: COLORS.white, borderWidth: 1, borderColor: COLORS.border }]}
                onPress={() => navigation.navigate('SalidaDeSede' as never)}
              >
                <Text style={[styles.cerrarButtonText, { color: COLORS.text.primary }]}>Cancelar (Salir de Sede)</Text>
              </TouchableOpacity>
            </View>
          ) : (
            <TouchableOpacity
              style={[styles.cerrarButton, { backgroundColor: COLORS.success }]}
              onPress={() => navigation.navigate('SalidaDeSede' as never)}
            >
              <Text style={styles.cerrarButtonText}>Salir de Sede</Text>
            </TouchableOpacity>
          )}
        </View>
      )}

      {/* Card de Situación Activa */}
      {situacionActiva ? (
        <View style={[styles.card, styles.situacionActivaCard]}>
          <View style={styles.cardHeader}>
            <Text style={styles.cardTitle}>Situación Activa</Text>
            <View style={[
              styles.tipoBadge,
              { backgroundColor: getTipoSituacionColor(situacionActiva.tipo_situacion) }
            ]}>
              <Text style={styles.tipoBadgeText}>{situacionActiva.tipo_situacion}</Text>
            </View>
          </View>
          <View style={styles.cardContent}>
            {situacionActiva.numero_situacion && (
              <View style={styles.infoRow}>
                <Text style={styles.infoLabel}>No. Situación:</Text>
                <Text style={styles.infoValue}>{situacionActiva.numero_situacion}</Text>
              </View>
            )}
            <View style={styles.infoRow}>
              <Text style={styles.infoLabel}>Inicio:</Text>
              <Text style={styles.infoValue}>
                {formatFecha(situacionActiva.created_at)}
              </Text>
            </View>
            {situacionActiva.ruta_codigo && (
              <View style={styles.infoRow}>
                <Text style={styles.infoLabel}>Ubicación:</Text>
                <Text style={styles.infoValue}>
                  {situacionActiva.ruta_codigo} Km {situacionActiva.km || '-'}
                </Text>
              </View>
            )}
            {situacionActiva.descripcion && (
              <View style={styles.descriptionRow}>
                <Text style={styles.infoLabel}>Descripción:</Text>
                <Text style={styles.descripcionText}>{situacionActiva.descripcion}</Text>
              </View>
            )}
          </View>
          <TouchableOpacity
            style={styles.cerrarButton}
            onPress={handleCerrarSituacion}
            disabled={isLoading}
          >
            {isLoading ? (
              <ActivityIndicator color="#fff" />
            ) : (
              <Text style={styles.cerrarButtonText}>Cerrar Situación</Text>
            )}
          </TouchableOpacity>
        </View>
      ) : (
        <View style={styles.card}>
          <Text style={styles.noSituacionText}>
            No hay situación activa
          </Text>
        </View>
      )}

      {/* Botones de acción */}
      {salidaActiva && !ingresoActivo && (
        <View style={styles.actionsContainer}>
          <Text style={styles.actionsTitle}>Reportar Situación</Text>

          <TouchableOpacity
            style={[styles.actionButton, styles.incidenteButton]}
            onPress={() => navigation.navigate('Incidente' as never)}
            disabled={!accesoInfo?.tiene_acceso}
          >
            <Text style={styles.actionButtonIcon}>🚗💥</Text>
            <Text style={styles.actionButtonText}>Hecho de Tránsito</Text>
            <Text style={styles.actionButtonSubtext}>Colisión, vuelco, atropello</Text>
          </TouchableOpacity>

          <TouchableOpacity
            style={[styles.actionButton, styles.asistenciaButton]}
            onPress={() => navigation.navigate('Asistencia' as never)}
            disabled={!accesoInfo?.tiene_acceso}
          >
            <Text style={styles.actionButtonIcon}>🔧</Text>
            <Text style={styles.actionButtonText}>Asistencia Vial</Text>
            <Text style={styles.actionButtonSubtext}>Pinchazo, desperfectos, varado</Text>
          </TouchableOpacity>

          <TouchableOpacity
            style={[styles.actionButton, styles.emergenciaButton]}
            onPress={() => navigation.navigate('Emergencia' as never)}
            disabled={!accesoInfo?.tiene_acceso}
          >
            <Text style={styles.actionButtonIcon}>⚠️</Text>
            <Text style={styles.actionButtonText}>Emergencia Vial</Text>
            <Text style={styles.actionButtonSubtext}>Derrumbe, inundación, caída</Text>
          </TouchableOpacity>

          <TouchableOpacity
            style={[styles.actionButton, styles.secondaryButton]}
            onPress={() => navigation.navigate('NuevaSituacion' as never)}
            disabled={!accesoInfo?.tiene_acceso}
          >
            <Text style={styles.secondaryButtonText}>+ Otra Situación</Text>
          </TouchableOpacity>

          <View style={styles.separator} />

          <Text style={styles.actionsTitle}>Gestión de Jornada</Text>

          <TouchableOpacity
            style={[styles.actionButton, styles.secondaryButton]}
            onPress={() => navigation.navigate('IngresoSede' as never)}
          >
            <Text style={styles.secondaryButtonText}>🏢 Ingresar a Sede</Text>
          </TouchableOpacity>

          <View style={styles.separator} />

          <TouchableOpacity
            style={[styles.actionButton, styles.secondaryButton]}
            onPress={() => setMostrarCambioRuta(true)}
          >
            <Text style={styles.secondaryButtonText}>🔄 Cambio de Ruta</Text>
          </TouchableOpacity>

          <View style={styles.separator} />

          <TouchableOpacity
            style={[styles.actionButton, styles.secondaryButton]}
            onPress={() => navigation.navigate('Bitacora' as never)}
          >
            <Text style={styles.secondaryButtonText}>Ver Bitácora</Text>
          </TouchableOpacity>
        </View>
      )}

      {/* Modal de cambio de ruta */}
      {mostrarCambioRuta && (
        <View style={styles.modalOverlay}>
          <View style={styles.modalContent}>
            <Text style={styles.modalTitle}>Cambiar Ruta</Text>
            <Text style={styles.modalSubtitle}>
              Ruta actual: {salidaActiva?.ruta_codigo || 'Sin ruta asignada'}
            </Text>

            <RutaSelector
              value={nuevaRutaId || undefined}
              onChange={(rutaId) => setNuevaRutaId(rutaId)}
              label="Nueva Ruta"
              required
            />

            <View style={styles.modalButtons}>
              <TouchableOpacity
                style={[styles.modalButton, styles.modalButtonCancel]}
                onPress={() => {
                  setMostrarCambioRuta(false);
                  setNuevaRutaId(null);
                }}
                disabled={cambiandoRuta}
              >
                <Text style={styles.modalButtonTextCancel}>Cancelar</Text>
              </TouchableOpacity>

              <TouchableOpacity
                style={[styles.modalButton, styles.modalButtonConfirm]}
                onPress={handleCambiarRuta}
                disabled={!nuevaRutaId || cambiandoRuta}
              >
                {cambiandoRuta ? (
                  <ActivityIndicator color="#fff" />
                ) : (
                  <Text style={styles.modalButtonTextConfirm}>Confirmar</Text>
                )}
              </TouchableOpacity>
            </View>
          </View>
        </View>
      )}

      {/* Mensaje de ayuda */}
      {!asignacion && (
        <View style={styles.helpBox}>
          <Text style={styles.helpText}>
            No tienes una unidad asignada. Contacta a tu encargado de sede para que te asigne una unidad permanente.
          </Text>
        </View>
      )}
      {asignacion && !salidaActiva && (
        <View style={styles.helpBox}>
          <Text style={styles.helpText}>
            Debes iniciar una salida para poder reportar situaciones y comenzar tu jornada laboral.
          </Text>
        </View>
      )}
      {ingresoActivo && !ingresoActivo.es_ingreso_final && (
        <View style={styles.helpBox}>
          <Text style={styles.helpText}>
            Estás en sede. No puedes reportar situaciones hasta que registres la salida de sede.
          </Text>
        </View>
      )}
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.background,
    paddingBottom: 80, // Add padding for bottom navigation/safe area
  },
  header: {
    backgroundColor: COLORS.primary,
    padding: 20,
    paddingTop: 10,
  },
  headerTop: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 10,
  },
  welcomeText: {
    fontSize: 16,
    color: COLORS.text.inverse,
    opacity: 0.9,
  },
  userName: {
    fontSize: 24,
    fontWeight: 'bold',
    color: COLORS.text.inverse,
  },
  logoutButton: {
    backgroundColor: 'rgba(255, 255, 255, 0.2)',
    paddingVertical: 8,
    paddingHorizontal: 16,
    borderRadius: 8,
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.3)',
  },
  logoutButtonText: {
    color: COLORS.white,
    fontSize: 14,
    fontWeight: '600',
  },
  accesoIndicator: {
    paddingVertical: 8,
    paddingHorizontal: 12,
    borderRadius: 8,
    marginTop: 5,
  },
  accesoText: {
    color: COLORS.white,
    fontSize: 14,
    fontWeight: '600',
    textAlign: 'center',
  },
  card: {
    backgroundColor: COLORS.white,
    margin: 16,
    marginBottom: 8,
    borderRadius: 12,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  situacionActivaCard: {
    borderLeftWidth: 4,
    borderLeftColor: COLORS.success,
  },
  warningCard: {
    backgroundColor: COLORS.warning + '20',
    borderWidth: 1,
    borderColor: COLORS.warning,
  },
  cardHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: 16,
    paddingBottom: 8,
    borderBottomWidth: 1,
    borderBottomColor: COLORS.border,
  },
  cardTitle: {
    fontSize: 18,
    fontWeight: '600',
    color: COLORS.text.primary,
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
  cardContent: {
    padding: 16,
  },
  infoRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 12,
  },
  descriptionRow: {
    marginTop: 8,
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
    marginTop: 4,
    lineHeight: 20,
  },
  warningText: {
    padding: 16,
    fontSize: 16,
    color: COLORS.warning,
    textAlign: 'center',
    fontWeight: '500',
  },
  noSituacionText: {
    padding: 20,
    fontSize: 16,
    color: COLORS.text.secondary,
    textAlign: 'center',
  },
  cerrarButton: {
    backgroundColor: COLORS.danger,
    margin: 16,
    marginTop: 0,
    padding: 14,
    borderRadius: 8,
    alignItems: 'center',
  },
  cerrarButtonText: {
    color: COLORS.white,
    fontSize: 16,
    fontWeight: '600',
  },
  actionsContainer: {
    padding: 16,
    paddingTop: 8,
  },
  actionButton: {
    padding: 16,
    borderRadius: 12,
    alignItems: 'center',
    marginBottom: 12,
  },
  primaryButton: {
    backgroundColor: COLORS.primary,
  },
  secondaryButton: {
    backgroundColor: COLORS.white,
    borderWidth: 2,
    borderColor: COLORS.primary,
  },
  actionButtonText: {
    color: COLORS.white,
    fontSize: 16,
    fontWeight: '600',
  },
  secondaryButtonText: {
    color: COLORS.primary,
    fontSize: 16,
    fontWeight: '600',
  },
  tertiaryButton: {
    backgroundColor: COLORS.white,
    borderWidth: 2,
    borderColor: COLORS.warning,
  },
  tertiaryButtonText: {
    color: COLORS.warning,
    fontSize: 16,
    fontWeight: '600',
  },
  actionsTitle: {
    fontSize: 18,
    fontWeight: '600',
    color: COLORS.text.primary,
    marginBottom: 12,
  },
  separator: {
    height: 1,
    backgroundColor: COLORS.border,
    marginVertical: 16,
  },
  incidenteButton: {
    backgroundColor: COLORS.danger,
  },
  asistenciaButton: {
    backgroundColor: COLORS.warning,
  },
  emergenciaButton: {
    backgroundColor: '#f97316', // Orange
  },
  actionButtonIcon: {
    fontSize: 32,
    marginBottom: 4,
  },
  actionButtonSubtext: {
    color: COLORS.white,
    fontSize: 12,
    opacity: 0.9,
    marginTop: 2,
  },
  helpBox: {
    backgroundColor: COLORS.info + '20',
    margin: 16,
    marginTop: 0,
    padding: 16,
    borderRadius: 8,
    borderLeftWidth: 4,
    borderLeftColor: COLORS.info,
  },
  helpText: {
    fontSize: 14,
    color: COLORS.text.primary,
    lineHeight: 20,
  },
  modalOverlay: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
  },
  modalContent: {
    backgroundColor: COLORS.white,
    borderRadius: 16,
    padding: 20,
    width: '100%',
    maxWidth: 400,
  },
  modalTitle: {
    fontSize: 20,
    fontWeight: '600',
    color: COLORS.text.primary,
    marginBottom: 8,
  },
  modalSubtitle: {
    fontSize: 14,
    color: COLORS.text.secondary,
    marginBottom: 20,
  },
  modalButtons: {
    flexDirection: 'row',
    gap: 12,
    marginTop: 20,
  },
  modalButton: {
    flex: 1,
    paddingVertical: 12,
    borderRadius: 8,
    alignItems: 'center',
  },
  modalButtonCancel: {
    backgroundColor: COLORS.background,
    borderWidth: 1,
    borderColor: COLORS.border,
  },
  modalButtonConfirm: {
    backgroundColor: COLORS.primary,
  },
  modalButtonTextCancel: {
    color: COLORS.text.primary,
    fontSize: 14,
    fontWeight: '600',
  },
  modalButtonTextConfirm: {
    color: COLORS.white,
    fontSize: 14,
    fontWeight: '600',
  },
});
