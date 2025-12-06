import { NavigatorScreenParams } from '@react-navigation/native';

// ========================================
// ROOT STACK (AUTH + MAIN)
// ========================================

export type RootStackParamList = {
  Auth: undefined;
  Main: NavigatorScreenParams<MainDrawerParamList>;
};

// ========================================
// MAIN DRAWER (ROLE-BASED)
// ========================================

export type MainDrawerParamList = {
  // BRIGADA screens
  BrigadaStack: NavigatorScreenParams<BrigadaStackParamList> | undefined;

  // COP screens
  COPStack: NavigatorScreenParams<COPStackParamList> | undefined;

  // ENCARGADO_SEDE screens
  SedeStack: NavigatorScreenParams<SedeStackParamList> | undefined;

  // Shared screens
  Perfil: undefined;
  Configuracion: undefined;
};

// ========================================
// BRIGADA STACK
// ========================================

export type BrigadaStackParamList = {
  BrigadaHome: undefined;
  NuevaSituacion: undefined;
  DetalleSituacion: { situacionId: number };
  Bitacora: undefined;
  ReportarIncidente: undefined;
};

// ========================================
// COP STACK
// ========================================

export type COPStackParamList = {
  COPHome: undefined;
  MapaUnidades: undefined;
  BitacoraUnidad: { unidadId: number; unidadCodigo: string };
  DetalleSituacionCOP: { situacionId: number };
  GestionGrupos: undefined;
  GestionMovimientos: undefined;
};

// ========================================
// ENCARGADO_SEDE STACK
// ========================================

export type SedeStackParamList = {
  SedeHome: undefined;
  MisUnidades: undefined;
  BitacoraUnidadSede: { unidadId: number; unidadCodigo: string };
};
